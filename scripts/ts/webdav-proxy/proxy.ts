export interface ProxyConfig {
  port: number;
  upstream: string;
  pathPrefix: string;
  allowedOrigins: string[];
}

const METHODS = [
  "OPTIONS",
  "GET",
  "HEAD",
  "PROPFIND",
  "MKCOL",
  "PUT",
  "DELETE",
];
const REQUEST_HEADERS = ["authorization", "content-type", "depth", "range"];
const HOP_HEADERS = [
  "connection",
  "keep-alive",
  "proxy-authenticate",
  "proxy-authorization",
  "te",
  "trailer",
  "transfer-encoding",
  "upgrade",
];

function stripHopHeaders(headers: Headers): void {
  for (const name of (headers.get("connection") ?? "").split(",")) {
    if (name.trim()) headers.delete(name.trim());
  }
  for (const name of HOP_HEADERS) headers.delete(name);
}

export function createHandler(
  config: ProxyConfig,
): (request: Request) => Promise<Response> {
  const upstream = new URL(config.upstream);
  const localOrigin = `http://127.0.0.1:${config.port}`;
  const prefix = config.pathPrefix.replace(/\/+$/, "");
  const allowedOrigins = new Set(config.allowedOrigins);
  if (
    !["https:", "http:"].includes(upstream.protocol) ||
    upstream.username || upstream.password || upstream.pathname !== "/" ||
    upstream.search || upstream.hash || !config.pathPrefix.startsWith("/") ||
    config.pathPrefix.includes("?") || config.pathPrefix.includes("#") ||
    allowedOrigins.size === 0
  ) {
    throw new Error("Invalid WebDAV proxy configuration");
  }
  const matchesPath = (path: string) =>
    prefix === "" || path === prefix || path.startsWith(`${prefix}/`);

  return async (request: Request): Promise<Response> => {
    const started = performance.now();
    const url = new URL(request.url);
    const origin = request.headers.get("origin");
    let status = 500;
    let failure: string | undefined;

    const addCors = (headers: Headers): void => {
      for (const name of [...headers.keys()]) {
        if (name.startsWith("access-control-")) headers.delete(name);
      }
      headers.append("Vary", "Origin");
      if (origin && allowedOrigins.has(origin)) {
        headers.set("Access-Control-Allow-Origin", origin);
        headers.set(
          "Access-Control-Expose-Headers",
          "ETag, Content-Length, Last-Modified, Content-Range, Accept-Ranges, DAV",
        );
      }
    };
    const reply = (code: number, message: string): Response => {
      status = code;
      const headers = new Headers({
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store",
      });
      addCors(headers);
      return new Response(request.method === "HEAD" ? null : message, {
        status,
        headers,
      });
    };

    try {
      if (url.origin !== localOrigin) {
        return reply(421, "Unexpected proxy host");
      }
      if (origin !== null && !allowedOrigins.has(origin)) {
        return reply(403, "Browser origin is not allowed");
      }
      if (!matchesPath(url.pathname)) {
        return reply(404, "Outside the WebDAV path");
      }
      if (!METHODS.includes(request.method)) {
        return reply(405, "Method is not allowed");
      }

      if (request.method === "OPTIONS") {
        const method = request.headers.get("access-control-request-method");
        const requestedHeaders =
          (request.headers.get("access-control-request-headers") ?? "")
            .split(",").map((name) => name.trim().toLowerCase()).filter(
              Boolean,
            );
        if (method && !METHODS.includes(method.toUpperCase())) {
          return reply(405, "Requested method is not allowed");
        }
        if (requestedHeaders.some((name) => !REQUEST_HEADERS.includes(name))) {
          return reply(400, "Requested header is not allowed");
        }
        const headers = new Headers({
          "Allow": METHODS.join(", "),
          "Vary":
            "Access-Control-Request-Method, Access-Control-Request-Headers",
        });
        addCors(headers);
        headers.set("Access-Control-Allow-Methods", METHODS.join(", "));
        headers.set("Access-Control-Allow-Headers", REQUEST_HEADERS.join(", "));
        headers.set("Access-Control-Max-Age", "600");
        status = 204;
        return new Response(null, { status, headers });
      }

      const target = new URL(upstream);
      // Assign the path instead of resolving it, so a request cannot select another host.
      target.pathname = url.pathname;
      target.search = url.search;
      const headers = new Headers(request.headers);
      stripHopHeaders(headers);
      for (
        const name of [
          "host",
          "origin",
          "referer",
          "cookie",
          "content-length",
          "accept-encoding",
        ]
      ) {
        headers.delete(name);
      }
      // Let Deno negotiate compression so fetch decodes the upstream body.
      const deadline = AbortSignal.timeout(300_000);
      const signal = AbortSignal.any([request.signal, deadline]);
      let response: Response;
      try {
        response = await fetch(target, {
          method: request.method,
          headers,
          body: ["GET", "HEAD"].includes(request.method) ? null : request.body,
          redirect: "manual",
          signal,
        });
      } catch {
        failure = deadline.aborted
          ? "upstream timeout"
          : "upstream connection failed";
        return reply(
          deadline.aborted ? 504 : 502,
          "Unable to reach the WebDAV server",
        );
      }

      const responseHeaders = new Headers(response.headers);
      stripHopHeaders(responseHeaders);
      responseHeaders.delete("set-cookie");
      if (
        request.method !== "HEAD" && responseHeaders.has("content-encoding")
      ) {
        // Deno fetch has already decoded the body; encoded length/encoding are now stale.
        responseHeaders.delete("content-encoding");
        responseHeaders.delete("content-length");
      }
      const location = responseHeaders.get("location");
      if (location) {
        const redirect = new URL(location, target);
        if (
          redirect.origin !== upstream.origin || redirect.username ||
          redirect.password ||
          !matchesPath(redirect.pathname)
        ) {
          await response.body?.cancel();
          failure = "upstream redirect left the configured endpoint";
          return reply(502, "WebDAV redirect left the configured endpoint");
        }
        responseHeaders.set(
          "Location",
          `${localOrigin}${redirect.pathname}${redirect.search}`,
        );
      }
      addCors(responseHeaders);
      status = response.status;
      return new Response(response.body, { status, headers: responseHeaders });
    } catch {
      failure = "invalid upstream response";
      return reply(502, "Invalid response from the WebDAV server");
    } finally {
      // Never log headers, query parameters, or bodies: these may contain credentials.
      console.log(JSON.stringify({
        method: request.method,
        status,
        durationMs: Math.round(performance.now() - started),
        ...(failure ? { failure } : {}),
      }));
    }
  };
}

if (import.meta.main) {
  const config: ProxyConfig = JSON.parse(Deno.args[0]);
  Deno.serve(
    { hostname: "127.0.0.1", port: config.port },
    createHandler(config),
  );
}
