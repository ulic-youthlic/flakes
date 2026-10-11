package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/url"
	"strconv"
	"strings"
)

// config is the JSON document passed as the only command-line argument.
type config struct {
	Port           int      `json:"port"`
	Upstream       string   `json:"upstream"`
	PathPrefix     string   `json:"pathPrefix"`
	AllowedOrigins []string `json:"allowedOrigins"`
}

// settings is a validated config.
type settings struct {
	listen   *url.URL // where browsers reach the proxy
	upstream *url.URL
	prefix   string // the served path, without a trailing slash; "" serves everything
	origins  map[string]bool
}

// parseConfig decodes a single JSON object that has no unknown fields.
func parseConfig(raw string) (config, error) {
	var cfg config
	dec := json.NewDecoder(strings.NewReader(raw))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&cfg); err != nil {
		return config{}, fmt.Errorf("decode configuration: %w", err)
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		return config{}, errors.New("configuration must be a single JSON value")
	}
	return cfg, nil
}

func (c config) validate() (settings, error) {
	if c.Port < 1 || c.Port > 65535 {
		return settings{}, errors.New("port must be between 1 and 65535")
	}
	upstream, err := parseOrigin(c.Upstream)
	if err != nil {
		return settings{}, fmt.Errorf("upstream: %w", err)
	}
	prefix, err := parsePathPrefix(c.PathPrefix)
	if err != nil {
		return settings{}, fmt.Errorf("pathPrefix: %w", err)
	}
	if len(c.AllowedOrigins) == 0 {
		return settings{}, errors.New("allowedOrigins must not be empty")
	}
	origins := make(map[string]bool, len(c.AllowedOrigins))
	for _, raw := range c.AllowedOrigins {
		origin, err := parseOrigin(raw)
		if err != nil {
			return settings{}, fmt.Errorf("allowedOrigins: %w", err)
		}
		// Browsers send origins in this exact form, and they are compared as strings.
		if origin.String() != raw {
			return settings{}, fmt.Errorf("allowedOrigins: %q is not in scheme://host[:port] form", raw)
		}
		origins[raw] = true
	}
	return settings{
		listen:   &url.URL{Scheme: "http", Host: net.JoinHostPort("127.0.0.1", strconv.Itoa(c.Port))},
		upstream: upstream,
		prefix:   prefix,
		origins:  origins,
	}, nil
}

// parseOrigin parses an HTTP(S) origin: a scheme and a host with an optional
// port, nothing else.
func parseOrigin(raw string) (*url.URL, error) {
	u, err := url.Parse(raw)
	if err != nil {
		// Don't wrap: the parse error repeats the input, which may hold credentials.
		return nil, errors.New("not a valid URL")
	}
	switch {
	case u.Scheme != "http" && u.Scheme != "https", u.Hostname() == "":
		return nil, errors.New("want an http or https URL with a host")
	case u.User != nil:
		return nil, errors.New("credentials are not allowed")
	case u.Opaque != "", u.Path != "" && u.Path != "/", u.RawQuery != "", u.ForceQuery, u.Fragment != "":
		return nil, errors.New("path, query, and fragment are not allowed")
	}
	if port := u.Port(); port != "" {
		if n, err := strconv.Atoi(port); err != nil || n < 1 || n > 65535 {
			return nil, fmt.Errorf("invalid port %q", port)
		}
	}
	u.Path, u.RawPath = "", ""
	return u, nil
}

// parsePathPrefix validates the URL path the proxy serves.
func parsePathPrefix(raw string) (string, error) {
	u, err := url.ParseRequestURI(raw)
	if err != nil || !strings.HasPrefix(raw, "/") || u.Host != "" || u.RawQuery != "" ||
		u.ForceQuery || strings.Contains(raw, "#") || !safePath(u.Path) {
		return "", errors.New("want an absolute path without traversal, query, or fragment")
	}
	return strings.TrimRight(u.Path, "/"), nil
}
