package main

import (
	"context"
	"errors"
	"io"
	"log"
	"log/slog"
	"net/http"
	"net/http/httputil"
	"net/url"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"time"
)

var methods = []string{
	"OPTIONS", "GET", "HEAD", "PROPFIND", "PROPPATCH", "MKCOL", "PUT", "DELETE",
	"COPY", "MOVE", "LOCK", "UNLOCK",
}

var requestHeaders = []string{
	"authorization", "content-type", "depth", "range", "destination", "overwrite",
	"if", "if-match", "if-none-match", "if-modified-since", "if-unmodified-since",
	"lock-token", "timeout",
}

var taggedURI = regexp.MustCompile(`<([^<>]*)>`)
var errLocation = errors.New("upstream location is outside the configured WebDAV endpoint")

type webdavProxy struct {
	upstream *url.URL
	local    *url.URL
	prefix   string
	origins  map[string]bool
	proxy    *httputil.ReverseProxy
	timeout  time.Duration
}

func parseOrigin(raw string) (*url.URL, error) {
	u, err := url.Parse(raw)
	if err != nil || u.Hostname() == "" || (u.Scheme != "http" && u.Scheme != "https") ||
		u.User != nil || u.Opaque != "" || (u.Path != "" && u.Path != "/") ||
		u.RawQuery != "" || u.ForceQuery || u.Fragment != "" {
		return nil, errors.New("expected an HTTP(S) origin without credentials, path, query, or fragment")
	}
	if port := u.Port(); port != "" {
		n, err := strconv.Atoi(port)
		if err != nil || n < 1 || n > 65535 {
			return nil, errors.New("invalid origin port")
		}
	}
	u.Path = ""
	u.RawPath = ""
	return u, nil
}

func newProxy(cfg config, transport http.RoundTripper) (*webdavProxy, error) {
	if cfg.Port < 1 || cfg.Port > 65535 {
		return nil, errors.New("port must be between 1 and 65535")
	}
	upstream, err := parseOrigin(cfg.Upstream)
	if err != nil {
		return nil, errors.New("upstream must be an HTTP(S) origin without credentials or a path")
	}
	prefix, err := url.ParseRequestURI(cfg.PathPrefix)
	if err != nil || !strings.HasPrefix(cfg.PathPrefix, "/") || prefix.Host != "" ||
		prefix.RawQuery != "" || prefix.ForceQuery || strings.Contains(cfg.PathPrefix, "#") || !safePath(prefix.Path) {
		return nil, errors.New("pathPrefix must be an absolute path without traversal, query, or fragment")
	}
	p := &webdavProxy{
		upstream: upstream,
		local:    &url.URL{Scheme: "http", Host: "127.0.0.1:" + strconv.Itoa(cfg.Port)},
		prefix:   strings.TrimRight(prefix.Path, "/"),
		origins:  make(map[string]bool),
		timeout:  5 * time.Minute,
	}
	for _, raw := range cfg.AllowedOrigins {
		origin, err := parseOrigin(raw)
		if err != nil || origin.String() != raw {
			return nil, errors.New("allowedOrigins must contain HTTP(S) origins without trailing slashes")
		}
		p.origins[raw] = true
	}
	if len(p.origins) == 0 {
		return nil, errors.New("allowedOrigins must not be empty")
	}
	if transport == nil {
		t := http.DefaultTransport.(*http.Transport).Clone()
		t.Proxy = nil
		// Keep compressed bytes and their metadata together; the browser decodes them.
		t.DisableCompression = true
		t.ResponseHeaderTimeout = p.timeout
		transport = t
	}
	p.proxy = &httputil.ReverseProxy{
		Transport: transport,
		ErrorLog:  log.New(io.Discard, "", 0),
		Rewrite: func(r *httputil.ProxyRequest) {
			// Copy paths directly, including RawPath, instead of resolving against a base URL.
			r.Out.URL.Scheme = p.upstream.Scheme
			r.Out.URL.Host = p.upstream.Host
			r.Out.Host = p.upstream.Host
			r.Out.URL.RawQuery = r.In.URL.RawQuery
			for name := range r.Out.Header {
				lower := strings.ToLower(name)
				if lower == "origin" || lower == "referer" || lower == "cookie" ||
					lower == "forwarded" || strings.HasPrefix(lower, "x-forwarded-") {
					r.Out.Header.Del(name)
				}
			}
		},
		ModifyResponse: func(response *http.Response) error {
			if location := response.Header.Get("Location"); location != "" {
				u, err := url.Parse(location)
				if err != nil {
					return errLocation
				}
				u = response.Request.URL.ResolveReference(u)
				if u.User != nil || !sameOrigin(u, p.upstream) || !p.matchesPath(u.Path) {
					return errLocation
				}
				u.Scheme, u.Host = p.local.Scheme, p.local.Host
				response.Header.Set("Location", u.String())
			}
			response.Header.Del("Set-Cookie")
			p.addCORS(response.Header, browserOrigin(response.Request))
			return nil
		},
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			code := http.StatusBadGateway
			if errors.Is(err, context.DeadlineExceeded) || errors.Is(r.Context().Err(), context.DeadlineExceeded) {
				code = http.StatusGatewayTimeout
			}
			p.reply(w, r, code, "Unable to reach the configured WebDAV endpoint")
		},
	}
	return p, nil
}

// A distinct key keeps the validated browser origin available after Rewrite removes its header.
type originKey struct{}

func browserOrigin(r *http.Request) string {
	if origin, ok := r.Context().Value(originKey{}).(string); ok {
		return origin
	}
	return r.Header.Get("Origin")
}

func safePath(path string) bool {
	if !strings.HasPrefix(path, "/") || strings.ContainsAny(path, "\\\x00\r\n") {
		return false
	}
	for _, segment := range strings.Split(path, "/") {
		if segment == "." || segment == ".." {
			return false
		}
	}
	return true
}

func (p *webdavProxy) matchesPath(path string) bool {
	return safePath(path) && (p.prefix == "" || path == p.prefix || strings.HasPrefix(path, p.prefix+"/"))
}

func sameOrigin(a, b *url.URL) bool {
	port := func(u *url.URL) string {
		if u.Port() != "" {
			return u.Port()
		}
		if u.Scheme == "https" {
			return "443"
		}
		return "80"
	}
	return a.Scheme == b.Scheme && strings.EqualFold(a.Hostname(), b.Hostname()) && port(a) == port(b)
}

func (p *webdavProxy) addCORS(h http.Header, origin string) {
	for name := range h {
		if strings.HasPrefix(strings.ToLower(name), "access-control-") {
			h.Del(name)
		}
	}
	h.Add("Vary", "Origin")
	if p.origins[origin] {
		h.Set("Access-Control-Allow-Origin", origin)
		h.Set("Access-Control-Expose-Headers", "ETag, Content-Length, Last-Modified, Content-Range, Accept-Ranges, DAV, Allow, Lock-Token, Location")
	}
}

func (p *webdavProxy) reply(w http.ResponseWriter, r *http.Request, code int, message string) {
	p.addCORS(w.Header(), browserOrigin(r))
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(code)
	if r.Method != http.MethodHead {
		_, _ = io.WriteString(w, message+"\n")
	}
}

func (p *webdavProxy) destination(raw string) (string, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", errors.New("invalid destination")
	}
	u = p.local.ResolveReference(u)
	if u.User != nil || u.Fragment != "" || !p.matchesPath(u.Path) ||
		(!sameOrigin(u, p.local) && !sameOrigin(u, p.upstream)) {
		return "", errors.New("destination is outside the configured WebDAV endpoint")
	}
	u.Scheme, u.Host = p.upstream.Scheme, p.upstream.Host
	return u.String(), nil
}

func (p *webdavProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	started := time.Now()
	recorded := &statusWriter{ResponseWriter: w}
	w = recorded
	defer func() {
		// Never log paths, query parameters, credentials, request headers, or bodies.
		slog.Info("request", "method", r.Method, "status", recorded.status, "durationMs", time.Since(started).Milliseconds())
	}()
	if r.Host != p.local.Host || (r.URL.IsAbs() && !sameOrigin(r.URL, p.local)) {
		p.reply(w, r, http.StatusMisdirectedRequest, "Unexpected proxy host")
		return
	}
	origin := r.Header.Get("Origin")
	if len(r.Header.Values("Origin")) > 1 || (origin != "" && !p.origins[origin]) {
		p.reply(w, r, http.StatusForbidden, "Browser origin is not allowed")
		return
	}
	if !p.matchesPath(r.URL.Path) {
		p.reply(w, r, http.StatusNotFound, "Outside the WebDAV path")
		return
	}
	if !slices.Contains(methods, r.Method) {
		w.Header().Set("Allow", strings.Join(methods, ", "))
		p.reply(w, r, http.StatusMethodNotAllowed, "Method is not allowed")
		return
	}
	if r.Method == http.MethodOptions {
		method := strings.ToUpper(strings.TrimSpace(r.Header.Get("Access-Control-Request-Method")))
		if method != "" && !slices.Contains(methods, method) {
			p.reply(w, r, http.StatusMethodNotAllowed, "Requested method is not allowed")
			return
		}
		for _, name := range strings.Split(strings.Join(r.Header.Values("Access-Control-Request-Headers"), ","), ",") {
			name = strings.ToLower(strings.TrimSpace(name))
			if name != "" && !slices.Contains(requestHeaders, name) {
				p.reply(w, r, http.StatusBadRequest, "Requested header is not allowed")
				return
			}
		}
		p.addCORS(w.Header(), origin)
		w.Header().Add("Vary", "Access-Control-Request-Method, Access-Control-Request-Headers, Access-Control-Request-Private-Network")
		w.Header().Set("Allow", strings.Join(methods, ", "))
		w.Header().Set("Access-Control-Allow-Methods", strings.Join(methods, ", "))
		w.Header().Set("Access-Control-Allow-Headers", strings.Join(requestHeaders, ", "))
		w.Header().Set("Access-Control-Max-Age", "600")
		if p.origins[origin] && r.Header.Get("Access-Control-Request-Private-Network") == "true" {
			w.Header().Set("Access-Control-Allow-Private-Network", "true")
		}
		w.WriteHeader(http.StatusNoContent)
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), p.timeout)
	defer cancel()
	r = r.Clone(context.WithValue(ctx, originKey{}, origin))
	if destination := r.Header.Get("Destination"); destination != "" {
		target, err := p.destination(destination)
		if err != nil {
			p.reply(w, r, http.StatusBadRequest, "Invalid WebDAV destination")
			return
		}
		r.Header.Set("Destination", target)
	}
	// DAV If headers may contain resource URLs as well as opaque lock tokens.
	var invalidTag bool
	ifHeader := taggedURI.ReplaceAllStringFunc(r.Header.Get("If"), func(tag string) string {
		raw := tag[1 : len(tag)-1]
		if !strings.HasPrefix(raw, "http://") && !strings.HasPrefix(raw, "https://") {
			return tag
		}
		target, err := p.destination(raw)
		if err != nil {
			invalidTag = true
		}
		return "<" + target + ">"
	})
	if invalidTag {
		p.reply(w, r, http.StatusBadRequest, "Invalid WebDAV resource tag")
		return
	}
	if ifHeader != "" {
		r.Header.Set("If", ifHeader)
	}
	p.proxy.ServeHTTP(w, r)
}

type statusWriter struct {
	http.ResponseWriter
	status int
}

func (w *statusWriter) WriteHeader(code int) {
	if code >= 200 && w.status == 0 {
		w.status = code
	}
	w.ResponseWriter.WriteHeader(code)
}

func (w *statusWriter) Write(b []byte) (int, error) {
	if w.status == 0 {
		w.WriteHeader(http.StatusOK)
	}
	return w.ResponseWriter.Write(b)
}

func (w *statusWriter) Unwrap() http.ResponseWriter { return w.ResponseWriter }
