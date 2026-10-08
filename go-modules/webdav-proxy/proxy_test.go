package main

import (
	"bytes"
	"compress/gzip"
	"errors"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"
)

const browser = "http://127.0.0.1:9097"
const local = "http://127.0.0.1:9098"
const auth = "Basic bW9jay11c2VyOm1vY2stcGFzc3dvcmQ="

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func testConfig(upstream string) config {
	return config{Port: 9098, Upstream: upstream, PathPrefix: "/dav", AllowedOrigins: []string{browser}}
}

func testProxy(t *testing.T, upstream string, transport http.RoundTripper) *webdavProxy {
	t.Helper()
	p, err := newProxy(testConfig(upstream), transport)
	if err != nil {
		t.Fatal(err)
	}
	if transport, ok := p.proxy.Transport.(*http.Transport); ok {
		t.Cleanup(transport.CloseIdleConnections)
	}
	return p
}

func request(method, path string, body io.Reader) *http.Request {
	r := httptest.NewRequest(method, local+path, body)
	r.Header.Set("Origin", browser)
	r.Header.Set("Authorization", auth)
	return r
}

func bodyText(t *testing.T, body io.ReadCloser) string {
	t.Helper()
	defer body.Close()
	data, err := io.ReadAll(body)
	if err != nil {
		t.Fatal(err)
	}
	return string(data)
}

func TestConfiguration(t *testing.T) {
	for name, change := range map[string]func(*config){
		"port":           func(c *config) { c.Port = 0 },
		"large port":     func(c *config) { c.Port = 65536 },
		"scheme":         func(c *config) { c.Upstream = "file:///tmp/dav" },
		"credentials":    func(c *config) { c.Upstream = "https://user:password@example.com" },
		"upstream path":  func(c *config) { c.Upstream = "https://example.com/dav" },
		"upstream query": func(c *config) { c.Upstream = "https://example.com?x=1" },
		"bad port":       func(c *config) { c.Upstream = "https://example.com:65536" },
		"empty prefix":   func(c *config) { c.PathPrefix = "" },
		"prefix query":   func(c *config) { c.PathPrefix = "/dav?x=1" },
		"traversal":      func(c *config) { c.PathPrefix = "/dav/%2e%2e" },
		"no origins":     func(c *config) { c.AllowedOrigins = nil },
		"wildcard":       func(c *config) { c.AllowedOrigins = []string{"*"} },
		"origin path":    func(c *config) { c.AllowedOrigins = []string{browser + "/app"} },
	} {
		t.Run(name, func(t *testing.T) {
			cfg := testConfig("https://example.com")
			change(&cfg)
			if _, err := newProxy(cfg, nil); err == nil {
				t.Fatal("invalid configuration was accepted")
			}
		})
	}
	for _, raw := range []string{`{`, `{"unexpected":true}`, `{} {}`, `null false`} {
		if _, err := parseConfig(raw); err == nil {
			t.Errorf("invalid JSON configuration accepted: %s", raw)
		}
	}
	if _, err := parseConfig(`{"port":9098,"upstream":"https://example.com","pathPrefix":"/dav","allowedOrigins":["http://127.0.0.1:9097"]}`); err != nil {
		t.Fatal(err)
	}
}

func TestPreflightAndRejectionsStayLocal(t *testing.T) {
	p := testProxy(t, "https://unreachable.invalid", roundTripFunc(func(*http.Request) (*http.Response, error) {
		t.Error("request unexpectedly reached upstream")
		return nil, errors.New("unexpected upstream call")
	}))
	r := request("OPTIONS", "/dav/", nil)
	r.Header.Set("Access-Control-Request-Method", "MOVE")
	r.Header.Set("Access-Control-Request-Headers", "Authorization, Content-Type, Depth, Destination, If, Lock-Token")
	r.Header.Set("Access-Control-Request-Private-Network", "true")
	w := httptest.NewRecorder()
	p.ServeHTTP(w, r)
	if w.Code != 204 || w.Header().Get("Access-Control-Allow-Origin") != browser ||
		!strings.Contains(w.Header().Get("Access-Control-Allow-Methods"), "MKCOL") ||
		w.Header().Get("Access-Control-Allow-Private-Network") != "true" || w.Body.Len() != 0 {
		t.Fatalf("invalid preflight response: %d %v %s", w.Code, w.Header(), w.Body.String())
	}
	for _, tc := range []struct {
		name   string
		modify func(*http.Request)
		status int
	}{
		{"origin", func(r *http.Request) { r.Header.Set("Origin", "https://untrusted.example") }, 403},
		{"null origin", func(r *http.Request) { r.Header.Set("Origin", "null") }, 403},
		{"duplicate origins", func(r *http.Request) { r.Header.Add("Origin", browser) }, 403},
		{"host", func(r *http.Request) { r.Host = "attacker.example:9098" }, 421},
		{"absolute URL", func(r *http.Request) { r.URL.Host = "attacker.example" }, 421},
		{"outside path", func(r *http.Request) { r.URL.Path = "/other" }, 404},
		{"prefix boundary", func(r *http.Request) { r.URL.Path = "/dav-other" }, 404},
		{"dot traversal", func(r *http.Request) { r.URL.Path = "/dav/../other" }, 404},
		{"encoded traversal", func(r *http.Request) { r.URL, _ = url.Parse(local + "/dav/%2e%2e/other") }, 404},
		{"backslash", func(r *http.Request) { r.URL.Path = "/dav/..\\other" }, 404},
		{"method", func(r *http.Request) { r.Method = "CONNECT" }, 405},
		{"preflight method", func(r *http.Request) { r.Header.Set("Access-Control-Request-Method", "TRACE") }, 405},
		{"preflight headers", func(r *http.Request) { r.Header.Set("Access-Control-Request-Headers", "Proxy-Authorization") }, 400},
	} {
		t.Run(tc.name, func(t *testing.T) {
			r := request("OPTIONS", "/dav/", nil)
			tc.modify(r)
			w := httptest.NewRecorder()
			p.ServeHTTP(w, r)
			if w.Code != tc.status {
				t.Fatalf("status = %d, want %d", w.Code, tc.status)
			}
			if r.Header.Get("Origin") != browser && w.Header().Get("Access-Control-Allow-Origin") != "" {
				t.Fatal("untrusted origin received CORS permission")
			}
		})
	}
}

func TestPROPFINDAndUpstreamErrors(t *testing.T) {
	const xml = `<D:multistatus xmlns:D="DAV:"><D:response><D:href>/dav/books/</D:href></D:response></D:multistatus>`
	upstream := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != auth {
			t.Error("authorization was lost")
		}
		if r.Host == "127.0.0.1:9098" {
			t.Error("local host leaked upstream")
		}
		for _, name := range []string{"Origin", "Cookie", "Referer", "Proxy-Authorization", "Forwarded", "X-Forwarded-For", "X-Private"} {
			if r.Header.Get(name) != "" {
				t.Errorf("%s leaked upstream", name)
			}
		}
		if r.URL.Path == "/dav/error" {
			w.WriteHeader(401)
			return
		}
		data, _ := io.ReadAll(r.Body)
		if r.Method != "PROPFIND" || r.URL.EscapedPath() != "/dav/My%20Books/%E4%B9%A6" ||
			r.URL.RawQuery != "depth=1&token=a%2Bb" || r.Header.Get("Depth") != "1" || string(data) != "<propfind/>" {
			t.Error("PROPFIND path, query, headers, or XML changed")
		}
		w.Header().Set("Content-Type", "application/xml")
		w.Header().Set("ETag", `"mock-etag"`)
		w.Header().Set("Connection", "X-Private")
		w.Header().Set("X-Private", "do not forward")
		w.Header().Set("Set-Cookie", "do not forward")
		w.Header().Set("Access-Control-Allow-Origin", "https://untrusted.example")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.WriteHeader(207)
		_, _ = io.WriteString(w, xml)
	}))
	defer upstream.Close()
	p := testProxy(t, upstream.URL, upstream.Client().Transport)
	r := request("PROPFIND", "/dav/My%20Books/%E4%B9%A6?depth=1&token=a%2Bb", strings.NewReader("<propfind/>"))
	r.Header.Set("Depth", "1")
	r.Header.Set("Content-Type", "application/xml")
	for _, name := range []string{"Cookie", "Referer", "Proxy-Authorization", "Forwarded", "X-Forwarded-For", "X-Private"} {
		r.Header.Set(name, "do not forward")
	}
	r.Header.Set("Connection", "X-Private")
	w := httptest.NewRecorder()
	p.ServeHTTP(w, r)
	if w.Code != 207 || w.Body.String() != xml || w.Header().Get("ETag") != `"mock-etag"` ||
		w.Header().Get("Access-Control-Allow-Origin") != browser {
		t.Fatalf("unexpected response: %d %v %s", w.Code, w.Header(), w.Body.String())
	}
	for _, name := range []string{"Set-Cookie", "X-Private", "Access-Control-Allow-Credentials"} {
		if w.Header().Get(name) != "" {
			t.Errorf("unexpected response header %s", name)
		}
	}
	w = httptest.NewRecorder()
	p.ServeHTTP(w, request("GET", "/dav/error", nil))
	if w.Code != 401 || w.Header().Get("Access-Control-Allow-Origin") != browser {
		t.Fatal("upstream errors must retain CORS headers")
	}
}

func TestRedirects(t *testing.T) {
	for _, location := range []string{
		"/dav/books/?page=2", "books/?page=2", "https://other.example/dav/",
		"/other/", "/dav/%2e%2e/other", "http://user:secret@example.com/dav/",
	} {
		t.Run(location, func(t *testing.T) {
			upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("Location", location)
				w.WriteHeader(301)
			}))
			defer upstream.Close()
			p := testProxy(t, upstream.URL, nil)
			w := httptest.NewRecorder()
			p.ServeHTTP(w, request("GET", "/dav/books", nil))
			want := 502
			if location == "/dav/books/?page=2" || location == "books/?page=2" {
				want = 301
				if w.Header().Get("Location") != local+"/dav/books/?page=2" {
					t.Fatal("redirect did not stay on local proxy")
				}
			}
			if w.Code != want || w.Header().Get("Access-Control-Allow-Origin") != browser {
				t.Fatalf("unexpected redirect status/headers: %d %v", w.Code, w.Header())
			}
		})
	}
}

func TestDestinationAndLockHeaders(t *testing.T) {
	for _, method := range []string{"COPY", "MOVE", "PROPPATCH", "LOCK", "UNLOCK"} {
		t.Run(method, func(t *testing.T) {
			upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				base := "http://" + r.Host
				if r.Method != method || r.Header.Get("Destination") != base+"/dav/new%20book" ||
					r.Header.Get("If") != "<"+base+"/dav/old> (<opaquelocktoken:123>)" ||
					r.Header.Get("Lock-Token") != "<opaquelocktoken:123>" || r.Header.Get("Overwrite") != "F" {
					t.Error("DAV destination or lock headers changed incorrectly")
				}
				w.Header().Set("Lock-Token", "<opaquelocktoken:456>")
				w.WriteHeader(201)
			}))
			defer upstream.Close()
			p := testProxy(t, upstream.URL, nil)
			r := request(method, "/dav/old", nil)
			r.Header.Set("Destination", local+"/dav/new%20book")
			r.Header.Set("If", "<"+local+"/dav/old> (<opaquelocktoken:123>)")
			r.Header.Set("Lock-Token", "<opaquelocktoken:123>")
			r.Header.Set("Overwrite", "F")
			w := httptest.NewRecorder()
			p.ServeHTTP(w, r)
			if w.Code != 201 || w.Header().Get("Lock-Token") != "<opaquelocktoken:456>" ||
				!strings.Contains(w.Header().Get("Access-Control-Expose-Headers"), "Lock-Token") {
				t.Fatalf("unexpected DAV response: %d %v", w.Code, w.Header())
			}
		})
	}
	p := testProxy(t, "https://unreachable.invalid", roundTripFunc(func(*http.Request) (*http.Response, error) {
		t.Error("unsafe destination reached upstream")
		return nil, errors.New("unexpected request")
	}))
	for _, destination := range []string{"https://other.example/dav/book", local + "/other/book", local + "/dav/%2e%2e/book"} {
		r := request("MOVE", "/dav/book", nil)
		r.Header.Set("Destination", destination)
		w := httptest.NewRecorder()
		p.ServeHTTP(w, r)
		if w.Code != 400 {
			t.Errorf("unsafe destination accepted: %s", destination)
		}
	}
}

func TestTransportErrorsHaveCORS(t *testing.T) {
	for _, timeout := range []bool{false, true} {
		transport := roundTripFunc(func(r *http.Request) (*http.Response, error) {
			if timeout {
				<-r.Context().Done()
				return nil, r.Context().Err()
			}
			return nil, errors.New("connection refused")
		})
		p := testProxy(t, "https://unreachable.invalid", transport)
		p.timeout = 10 * time.Millisecond
		w := httptest.NewRecorder()
		p.ServeHTTP(w, request("GET", "/dav/book", nil))
		want := 502
		if timeout {
			want = 504
		}
		if w.Code != want || w.Header().Get("Access-Control-Allow-Origin") != browser {
			t.Fatalf("unexpected transport error: %d %v", w.Code, w.Header())
		}
	}
}

func startHTTPProxy(t *testing.T, upstream string) (*httptest.Server, *http.Client) {
	t.Helper()
	server := httptest.NewUnstartedServer(nil)
	port := server.Listener.Addr().(*net.TCPAddr).Port
	cfg := testConfig(upstream)
	cfg.Port = port
	p, err := newProxy(cfg, nil)
	if err != nil {
		t.Fatal(err)
	}
	server.Config.Handler = p
	server.Start()
	t.Cleanup(server.Close)
	t.Cleanup(p.proxy.Transport.(*http.Transport).CloseIdleConnections)
	transport := http.DefaultTransport.(*http.Transport).Clone()
	transport.DisableCompression = true
	t.Cleanup(transport.CloseIdleConnections)
	return server, &http.Client{Transport: transport, Timeout: 5 * time.Second}
}

func TestHTTPFileOperations(t *testing.T) {
	var stored []byte
	var mu sync.Mutex
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		if r.Header.Get("Authorization") != auth {
			t.Error("authorization lost")
		}
		switch r.Method {
		case "MKCOL":
			if len(r.TransferEncoding) != 0 || r.ContentLength != 0 {
				t.Error("empty MKCOL acquired a framed body")
				w.WriteHeader(415)
				return
			}
			if !strings.HasSuffix(r.URL.Path, "/") {
				w.Header().Set("Location", r.URL.Path+"/")
				w.WriteHeader(301)
				return
			}
			w.WriteHeader(201)
		case "PUT":
			if r.ContentLength != 262144 || len(r.TransferEncoding) != 0 {
				t.Error("upload size was lost")
			}
			stored, _ = io.ReadAll(r.Body)
			w.WriteHeader(201)
		case "DELETE":
			if r.Header.Get("Depth") != "infinity" {
				t.Error("Depth header lost")
			}
			stored = nil
			w.WriteHeader(204)
		default:
			if stored == nil {
				w.WriteHeader(404)
				return
			}
			w.Header().Set("Content-Length", strconv.Itoa(len(stored)))
			w.Header().Set("ETag", `"book"`)
			if r.Method != "HEAD" {
				_, _ = w.Write(stored)
			}
		}
	}))
	defer upstream.Close()
	server, client := startHTTPProxy(t, upstream.URL)
	// Keep DAV methods intact when the browser retries a directory redirect.
	client.CheckRedirect = func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }
	do := func(method, target string, data io.Reader) *http.Response {
		t.Helper()
		r, _ := http.NewRequest(method, target, data)
		r.Header.Set("Origin", browser)
		r.Header.Set("Authorization", auth)
		r.Header.Set("Depth", "infinity")
		response, err := client.Do(r)
		if err != nil {
			t.Fatal(err)
		}
		if response.Header.Get("Access-Control-Allow-Origin") != browser {
			t.Fatal("missing CORS header")
		}
		return response
	}
	created := do("MKCOL", server.URL+"/dav/books", nil)
	if created.StatusCode != 301 || created.Header.Get("Location") != server.URL+"/dav/books/" {
		t.Fatalf("unexpected directory redirect: %v", created)
	}
	_ = bodyText(t, created.Body)
	created = do("MKCOL", created.Header.Get("Location"), nil)
	if created.StatusCode != 201 {
		t.Fatal("MKCOL failed")
	}
	_ = bodyText(t, created.Body)
	data := bytes.Repeat([]byte{0, 1, 2, 250}, 65536)
	uploaded := do("PUT", server.URL+"/dav/books/book.epub", bytes.NewReader(data))
	if uploaded.StatusCode != 201 {
		t.Fatal("PUT failed")
	}
	_ = bodyText(t, uploaded.Body)
	head := do("HEAD", server.URL+"/dav/books/book.epub", nil)
	if head.StatusCode != 200 || head.ContentLength != int64(len(data)) || head.Header.Get("ETag") != `"book"` || bodyText(t, head.Body) != "" {
		t.Fatal("HEAD metadata or body changed")
	}
	downloaded := do("GET", server.URL+"/dav/books/book.epub", nil)
	if bodyText(t, downloaded.Body) != string(data) {
		t.Fatal("binary file changed")
	}
	deleted := do("DELETE", server.URL+"/dav/books/book.epub", nil)
	if deleted.StatusCode != 204 {
		t.Fatal("DELETE failed")
	}
	_ = bodyText(t, deleted.Body)
	head = do("HEAD", server.URL+"/dav/books/book.epub", nil)
	if head.StatusCode != 404 || bodyText(t, head.Body) != "" {
		t.Fatal("deleted file is still present")
	}
}

func TestResponseStreamsBeforeUpstreamCompletes(t *testing.T) {
	release := make(chan struct{})
	var once sync.Once
	unblock := func() { once.Do(func() { close(release) }) }
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "first")
		w.(http.Flusher).Flush()
		<-release
		_, _ = io.WriteString(w, "second")
	}))
	defer upstream.Close()
	defer unblock()
	server, client := startHTTPProxy(t, upstream.URL)
	response, err := client.Get(server.URL + "/dav/book")
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	first := make([]byte, 5)
	if _, err := io.ReadFull(response.Body, first); err != nil || string(first) != "first" {
		t.Fatalf("initial bytes were not streamed: %q %v", first, err)
	}
	if response.Header.Get("Access-Control-Allow-Origin") != "" {
		t.Fatal("a non-browser request received an origin grant")
	}
	unblock()
	if bodyText(t, response.Body) != "second" {
		t.Fatal("stream was truncated")
	}
}

func TestLogsDoNotContainCredentialsOrURLs(t *testing.T) {
	var logs bytes.Buffer
	previous := slog.Default()
	slog.SetDefault(slog.New(slog.NewJSONHandler(&logs, nil)))
	defer slog.SetDefault(previous)
	p := testProxy(t, "https://example.com", roundTripFunc(func(*http.Request) (*http.Response, error) {
		return nil, errors.New("https://example.com/dav/private?token=secret")
	}))
	r := request("GET", "/dav/private?token=secret", nil)
	w := httptest.NewRecorder()
	p.ServeHTTP(w, r)
	for _, secret := range []string{auth, "example.com", "private", "token", "secret"} {
		if strings.Contains(logs.String(), secret) {
			t.Errorf("request log contains %q", secret)
		}
	}
	if !strings.Contains(logs.String(), `"status":502`) {
		t.Fatal("request status missing from log")
	}
}

func TestCompressionAndRange(t *testing.T) {
	var compressed bytes.Buffer
	gz := gzip.NewWriter(&compressed)
	_, _ = io.WriteString(gz, strings.Repeat("WebDAV content ", 100))
	_ = gz.Close()
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Range") == "bytes=2-4" {
			w.Header().Set("Content-Range", "bytes 2-4/10")
			w.Header().Set("Accept-Ranges", "bytes")
			w.WriteHeader(206)
			_, _ = io.WriteString(w, "234")
			return
		}
		w.Header().Set("Content-Encoding", "gzip")
		w.Header().Set("Content-Length", strconv.Itoa(compressed.Len()))
		_, _ = w.Write(compressed.Bytes())
	}))
	defer upstream.Close()
	p := testProxy(t, upstream.URL, nil)
	w := httptest.NewRecorder()
	p.ServeHTTP(w, request("GET", "/dav/book", nil))
	if !bytes.Equal(w.Body.Bytes(), compressed.Bytes()) || w.Header().Get("Content-Encoding") != "gzip" ||
		w.Header().Get("Content-Length") != strconv.Itoa(compressed.Len()) {
		t.Fatal("compression bytes and headers no longer agree")
	}
	r := request("GET", "/dav/book", nil)
	r.Header.Set("Range", "bytes=2-4")
	w = httptest.NewRecorder()
	p.ServeHTTP(w, r)
	if w.Code != 206 || w.Body.String() != "234" || w.Header().Get("Content-Range") != "bytes 2-4/10" {
		t.Fatal("range request was not preserved")
	}
}
