package main

import (
	"log/slog"
	"net/http"
	"time"
)

// logRequests logs the method, status, and duration of every request. It
// never logs paths, queries, headers, or bodies, which can hold credentials.
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		sw := &statusWriter{ResponseWriter: w}
		// Deferred, so that responses aborted with a panic are logged too.
		defer func() {
			slog.Info("request", "method", r.Method, "status", sw.status, "durationMs", time.Since(start).Milliseconds())
		}()
		next.ServeHTTP(sw, r)
	})
}

// statusWriter records the final (non-1xx) status of a response.
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

// Unwrap lets http.ResponseController reach the underlying writer, to flush
// streamed responses.
func (w *statusWriter) Unwrap() http.ResponseWriter { return w.ResponseWriter }
