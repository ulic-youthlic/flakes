package main

import (
	"errors"
	"net/url"
	"regexp"
	"strings"
)

var (
	errOutside  = errors.New("URL is outside the WebDAV endpoint")
	errLocation = errors.New("upstream redirected outside the WebDAV endpoint")
)

// taggedURL matches the <...> productions of a WebDAV If header.
var taggedURL = regexp.MustCompile(`<[^<>]*>`)

// upstreamURL takes a URL the client sent (a Destination or an If resource
// tag) and returns it on the upstream. It must point into the served path,
// on either the proxy or the upstream.
func (s settings) upstreamURL(raw string) (string, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", errOutside
	}
	u = s.listen.ResolveReference(u)
	if u.User != nil || u.Fragment != "" || !s.matchesPath(u.Path) ||
		(!sameOrigin(u, s.listen) && !sameOrigin(u, s.upstream)) {
		return "", errOutside
	}
	u.Scheme, u.Host = s.upstream.Scheme, s.upstream.Host
	return u.String(), nil
}

// localURL takes a Location the upstream sent in reply to a request for base
// and returns it on the proxy. It must point into the served path on the
// upstream.
func (s settings) localURL(base *url.URL, raw string) (string, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", errLocation
	}
	u = base.ResolveReference(u)
	if u.User != nil || !sameOrigin(u, s.upstream) || !s.matchesPath(u.Path) {
		return "", errLocation
	}
	u.Scheme, u.Host = s.listen.Scheme, s.listen.Host
	return u.String(), nil
}

// rewriteIf points the http(s) tags of a WebDAV If header at the upstream.
// Other tags, such as opaquelocktoken: state tokens, pass through unchanged.
func (s settings) rewriteIf(header string) (string, error) {
	var err error
	rewritten := taggedURL.ReplaceAllStringFunc(header, func(tag string) string {
		raw := tag[1 : len(tag)-1]
		if err != nil || !strings.HasPrefix(raw, "http://") && !strings.HasPrefix(raw, "https://") {
			return tag
		}
		target, tagErr := s.upstreamURL(raw)
		if tagErr != nil {
			err = tagErr
			return tag
		}
		return "<" + target + ">"
	})
	return rewritten, err
}

// matchesPath reports whether path lies inside the served path.
func (s settings) matchesPath(path string) bool {
	return safePath(path) && (s.prefix == "" || path == s.prefix || strings.HasPrefix(path, s.prefix+"/"))
}

// safePath reports whether path is absolute, has no . or .. segments, and has
// no characters some servers treat as separators or line ends.
func safePath(path string) bool {
	if !strings.HasPrefix(path, "/") || strings.ContainsAny(path, "\\\x00\r\n") {
		return false
	}
	for segment := range strings.SplitSeq(path, "/") {
		if segment == "." || segment == ".." {
			return false
		}
	}
	return true
}

func sameOrigin(a, b *url.URL) bool {
	return a.Scheme == b.Scheme && strings.EqualFold(a.Hostname(), b.Hostname()) &&
		effectivePort(a) == effectivePort(b)
}

// effectivePort returns u's port, or the default port of its scheme.
func effectivePort(u *url.URL) string {
	if port := u.Port(); port != "" {
		return port
	}
	if u.Scheme == "https" {
		return "443"
	}
	return "80"
}
