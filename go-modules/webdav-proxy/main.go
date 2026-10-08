package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

type config struct {
	Port           int      `json:"port"`
	Upstream       string   `json:"upstream"`
	PathPrefix     string   `json:"pathPrefix"`
	AllowedOrigins []string `json:"allowedOrigins"`
}

func parseConfig(raw string) (config, error) {
	var cfg config
	decoder := json.NewDecoder(strings.NewReader(raw))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&cfg); err != nil {
		return cfg, errors.New("invalid JSON configuration")
	}
	if err := decoder.Decode(new(any)); err != io.EOF {
		return cfg, errors.New("expected exactly one JSON configuration")
	}
	return cfg, nil
}

func run(args []string) error {
	if len(args) == 1 && (args[0] == "--help" || args[0] == "-h") {
		fmt.Println(`Usage: webdav-proxy '{"port":9098,"upstream":"https://example.com","pathPrefix":"/dav","allowedOrigins":["http://127.0.0.1:9097"]}'`)
		return nil
	}
	if len(args) != 1 {
		return errors.New("usage: webdav-proxy JSON_CONFIG (see --help)")
	}
	cfg, err := parseConfig(args[0])
	if err != nil {
		return err
	}
	proxy, err := newProxy(cfg, nil)
	if err != nil {
		return err
	}
	server := &http.Server{
		Addr:              proxy.local.Host,
		Handler:           proxy,
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if server.Shutdown(shutdown) != nil {
			_ = server.Close()
		}
	}()
	slog.Info("starting WebDAV proxy", "listen", server.Addr)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))
	if err := run(os.Args[1:]); err != nil {
		slog.Error("WebDAV proxy stopped", "error", err)
		os.Exit(1)
	}
}
