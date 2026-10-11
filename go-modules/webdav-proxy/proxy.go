package main

import (
	"context"
	"errors"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"slices"
	"strings"
	"time"
)

// methods are the HTTP and WebDAV methods the proxy accepts.
var methods = []string{
	"OPTIONS", "GET", "HEAD", "PROPFIND", "PROPPATCH", "MKCOL", "PUT", "DELETE",
	"COPY", "MOVE", "LOCK", "UNLOCK",
}

// requestHeaders are the headers a browser may send, in lower case as they
// appear in Access-Control-Request-Headers.
var requestHeaders = []string{
	"authorization", "content-type", "depth", "range", "destination", "overwrite",
	"if", "if-match", "if-none-match", "if-modified-since", "if-unmodified-since",
	"lock-token", "timeout",
}

var (
	allowMethods = strings.Join(methods, ", ")
	allowHeaders = strings.Join(requestHeaders, ", ")
)

// exposeHeaders are the response headers scripts on an allowed origin may read.
const exposeHeaders = "ETag, Content-Length, Last-Modified, Content-Range, Accept-Ranges, DAV, Allow, Lock-Token, Location"

// webdavProxy forwards WebDAV requests from the allowed browser origins to the
// upstream, and gives those origins CORS access to the responses.
type webdavProxy struct {
	settings
	timeout time.Duration // limit for one proxied request
	proxy   *httputil.ReverseProxy
}

// newProxy validates cfg and builds the proxy. A nil transport means direct
// connections to the upstream.
func newProxy(cfg config, transport http.RoundTripper) (*webdavProxy, error) {
	s, err := cfg.validate()
	if err != nil {
		return nil, err
	}
	p := &webdavProxy{settings: s, timeout: transferTimeout}
	if transport == nil {
		transport = newTransport(p.timeout)
	}
	p.proxy = &httputil.ReverseProxy{
		Transport:      transport,
		Rewrite:        p.rewrite,
		ModifyResponse: p.modifyResponse,
		ErrorHandler:   p.handleError,
		// handleError answers every error; don't log URLs.
		ErrorLog: log.New(io.Discard, "", 0),
	}
	return p, nil
}

func newTransport(responseHeaderTimeout time.Duration) *http.Transport {
	t := http.DefaultTransport.(*http.Transport).Clone()
	// Never send the browser's credentials through an environment proxy.
	t.Proxy = nil
	// Keep compressed bytes and their metadata together; the browser decodes them.
	t.DisableCompression = true
	t.ResponseHeaderTimeout = responseHeaderTimeout
	return t
}

// ServeHTTP answers CORS preflights and rejected requests itself, and
// forwards all other requests.
func (p *webdavProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if err := p.checkRequest(r); err != nil {
		p.fail(w, r, err)
		return
	}
	if r.Method == http.MethodOptions {
		p.servePreflight(w, r)
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), p.timeout)
	defer cancel()
	out := r.Clone(context.WithValue(ctx, originKey{}, r.Header.Get("Origin")))
	if err := p.rewriteDAVHeaders(out.Header); err != nil {
		p.fail(w, r, err)
		return
	}
	p.proxy.ServeHTTP(w, out)
}

// An httpError is a request error the proxy answers itself.
type httpError struct {
	code int
	msg  string
}

func (e *httpError) Error() string { return e.msg }

// checkRequest rejects requests for another host, from an untrusted origin,
// outside the served path, or with a method the proxy doesn't forward.
func (p *webdavProxy) checkRequest(r *http.Request) error {
	if r.Host != p.listen.Host || (r.URL.IsAbs() && !sameOrigin(r.URL, p.listen)) {
		return &httpError{http.StatusMisdirectedRequest, "Unexpected proxy host"}
	}
	if origin := r.Header.Get("Origin"); len(r.Header.Values("Origin")) > 1 || (origin != "" && !p.origins[origin]) {
		return &httpError{http.StatusForbidden, "Browser origin is not allowed"}
	}
	if !p.matchesPath(r.URL.Path) {
		return &httpError{http.StatusNotFound, "Outside the WebDAV path"}
	}
	if !slices.Contains(methods, r.Method) {
		return &httpError{http.StatusMethodNotAllowed, "Method is not allowed"}
	}
	return nil
}

// servePreflight answers OPTIONS requests, CORS preflights included, without
// asking the upstream.
func (p *webdavProxy) servePreflight(w http.ResponseWriter, r *http.Request) {
	method := strings.ToUpper(strings.TrimSpace(r.Header.Get("Access-Control-Request-Method")))
	if method != "" && !slices.Contains(methods, method) {
		p.fail(w, r, &httpError{http.StatusMethodNotAllowed, "Requested method is not allowed"})
		return
	}
	for name := range strings.SplitSeq(strings.Join(r.Header.Values("Access-Control-Request-Headers"), ","), ",") {
		name = strings.ToLower(strings.TrimSpace(name))
		if name != "" && !slices.Contains(requestHeaders, name) {
			p.fail(w, r, &httpError{http.StatusBadRequest, "Requested header is not allowed"})
			return
		}
	}
	origin := r.Header.Get("Origin")
	h := w.Header()
	p.addCORS(h, origin)
	h.Add("Vary", "Access-Control-Request-Method, Access-Control-Request-Headers, Access-Control-Request-Private-Network")
	h.Set("Allow", allowMethods)
	h.Set("Access-Control-Allow-Methods", allowMethods)
	h.Set("Access-Control-Allow-Headers", allowHeaders)
	h.Set("Access-Control-Max-Age", "600")
	if p.origins[origin] && r.Header.Get("Access-Control-Request-Private-Network") == "true" {
		h.Set("Access-Control-Allow-Private-Network", "true")
	}
	w.WriteHeader(http.StatusNoContent)
}

// rewriteDAVHeaders points the URLs in the Destination and If headers at the
// upstream. Each header may appear only once: forwarding a repeated one would
// let its unchecked copies through.
func (p *webdavProxy) rewriteDAVHeaders(h http.Header) error {
	for _, name := range []string{"Destination", "If"} {
		if len(h.Values(name)) > 1 {
			return &httpError{http.StatusBadRequest, "Repeated " + name + " header"}
		}
	}
	if destination := h.Get("Destination"); destination != "" {
		target, err := p.upstreamURL(destination)
		if err != nil {
			return &httpError{http.StatusBadRequest, "Invalid WebDAV destination"}
		}
		h.Set("Destination", target)
	}
	if condition := h.Get("If"); condition != "" {
		rewritten, err := p.rewriteIf(condition)
		if err != nil {
			return &httpError{http.StatusBadRequest, "Invalid WebDAV resource tag"}
		}
		h.Set("If", rewritten)
	}
	return nil
}

// rewrite sends the request to the upstream with its path and query exactly as
// received, and without the headers that describe the browser's context.
func (p *webdavProxy) rewrite(r *httputil.ProxyRequest) {
	// Set the URL fields directly; ProxyRequest.SetURL would join and
	// re-encode the path.
	r.Out.URL.Scheme = p.upstream.Scheme
	r.Out.URL.Host = p.upstream.Host
	r.Out.Host = p.upstream.Host
	// ReverseProxy drops query parameters it can't parse before calling
	// Rewrite; forward the query as the client sent it.
	r.Out.URL.RawQuery = r.In.URL.RawQuery
	for name := range r.Out.Header {
		if browserContextHeader(name) {
			r.Out.Header.Del(name)
		}
	}
}

func browserContextHeader(name string) bool {
	switch name = strings.ToLower(name); name {
	case "origin", "referer", "cookie", "forwarded":
		return true
	}
	return strings.HasPrefix(name, "x-forwarded-")
}

// modifyResponse keeps redirects on the proxy, drops cookies, and replaces the
// upstream's CORS headers with the proxy's.
func (p *webdavProxy) modifyResponse(resp *http.Response) error {
	if location := resp.Header.Get("Location"); location != "" {
		local, err := p.localURL(resp.Request.URL, location)
		if err != nil {
			return err
		}
		resp.Header.Set("Location", local)
	}
	resp.Header.Del("Set-Cookie")
	p.addCORS(resp.Header, browserOrigin(resp.Request))
	return nil
}

// handleError answers a failed upstream request, or a response modifyResponse
// rejected.
func (p *webdavProxy) handleError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, errLocation):
		p.fail(w, r, &httpError{http.StatusBadGateway, "The WebDAV endpoint redirected outside its path"})
	case errors.Is(err, context.DeadlineExceeded), errors.Is(r.Context().Err(), context.DeadlineExceeded):
		p.fail(w, r, &httpError{http.StatusGatewayTimeout, "The WebDAV endpoint did not answer in time"})
	default:
		p.fail(w, r, &httpError{http.StatusBadGateway, "Unable to reach the configured WebDAV endpoint"})
	}
}

// fail answers r with err as plain text, keeping the CORS headers so that the
// browser app can read the error.
func (p *webdavProxy) fail(w http.ResponseWriter, r *http.Request, err error) {
	he := &httpError{http.StatusInternalServerError, "Internal error"}
	errors.As(err, &he)
	h := w.Header()
	if he.code == http.StatusMethodNotAllowed {
		h.Set("Allow", allowMethods)
	}
	p.addCORS(h, browserOrigin(r))
	h.Set("Content-Type", "text/plain; charset=utf-8")
	h.Set("Cache-Control", "no-store")
	w.WriteHeader(he.code)
	if r.Method != http.MethodHead {
		_, _ = io.WriteString(w, he.msg+"\n")
	}
}

// addCORS replaces any CORS headers in h with the proxy's, which grant access
// to allowed origins only.
func (p *webdavProxy) addCORS(h http.Header, origin string) {
	for name := range h {
		if strings.HasPrefix(strings.ToLower(name), "access-control-") {
			h.Del(name)
		}
	}
	h.Add("Vary", "Origin")
	if p.origins[origin] {
		h.Set("Access-Control-Allow-Origin", origin)
		h.Set("Access-Control-Expose-Headers", exposeHeaders)
	}
}

// originKey carries the browser origin past rewrite, which removes the Origin
// header from the forwarded request.
type originKey struct{}

func browserOrigin(r *http.Request) string {
	if origin, ok := r.Context().Value(originKey{}).(string); ok {
		return origin
	}
	return r.Header.Get("Origin")
}
