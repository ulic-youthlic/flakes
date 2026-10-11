// Command webdav-proxy lets a browser app use a WebDAV server that sends no
// CORS headers. It listens on 127.0.0.1, forwards requests from the allowed
// browser origins to a single upstream origin, and adds CORS headers for
// those origins to the responses.
//
// Usage:
//
//	webdav-proxy '{"port":9098,"upstream":"https://example.com","pathPrefix":"/dav","allowedOrigins":["http://127.0.0.1:9097"]}'
package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

const (
	// transferTimeout limits one proxied request. It matches the 5-minute
	// limit Readest sets on its own WebDAV transfers.
	transferTimeout = 5 * time.Minute
	// serverGrace keeps the server's connection deadlines past the transfer
	// deadline, so a timed-out transfer can still get its 504 response.
	serverGrace       = 30 * time.Second
	readHeaderTimeout = 10 * time.Second
	idleTimeout       = 60 * time.Second
	shutdownTimeout   = 10 * time.Second
)

const usage = `Usage: webdav-proxy '{"port":9098,"upstream":"https://example.com","pathPrefix":"/dav","allowedOrigins":["http://127.0.0.1:9097"]}'`

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	err := run(ctx, os.Args[1:], os.Stdout)
	stop()
	if err != nil {
		slog.Error("WebDAV proxy stopped", "error", err)
		os.Exit(1)
	}
}

// run serves the proxy described by the JSON configuration in args until ctx
// is done.
func run(ctx context.Context, args []string, stdout io.Writer) error {
	if len(args) == 1 && (args[0] == "-h" || args[0] == "--help") {
		_, err := fmt.Fprintln(stdout, usage)
		return err
	}
	if len(args) != 1 {
		return errors.New("usage: webdav-proxy JSON_CONFIG (see --help)")
	}
	cfg, err := parseConfig(args[0])
	if err != nil {
		return err
	}
	p, err := newProxy(cfg, nil)
	if err != nil {
		return err
	}
	ln, err := net.Listen("tcp", p.listen.Host)
	if err != nil {
		return err
	}
	slog.Info("starting WebDAV proxy", "listen", ln.Addr().String())
	return serve(ctx, newServer(p), ln)
}

// newServer returns the HTTP server for p. Its deadlines keep any client,
// however slowly it sends or reads, from holding a connection longer than one
// transfer may take.
func newServer(p *webdavProxy) *http.Server {
	return &http.Server{
		Handler:           logRequests(p),
		ReadHeaderTimeout: readHeaderTimeout,
		ReadTimeout:       p.timeout + serverGrace,
		WriteTimeout:      p.timeout + serverGrace,
		IdleTimeout:       idleTimeout,
	}
}

// serve runs srv on ln in its own goroutine, which reports back on a channel,
// until either srv fails or ctx is done. It then shuts srv down and waits
// up to shutdownTimeout for active requests to finish.
func serve(ctx context.Context, srv *http.Server, ln net.Listener) error {
	// Unbuffered: every path below receives from served exactly once.
	served := make(chan error)
	go func() { served <- srv.Serve(ln) }()

	select {
	case err := <-served:
		return err
	case <-ctx.Done():
	}

	stopCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), shutdownTimeout)
	defer cancel()
	// Serve returns as soon as Shutdown closes the listener, while Shutdown
	// only returns once every connection is idle, so wait on Shutdown.
	stopErr := srv.Shutdown(stopCtx)
	if err := <-served; !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	if stopErr != nil {
		slog.Warn("closing connections still active after the shutdown timeout")
		return srv.Close()
	}
	return nil
}
