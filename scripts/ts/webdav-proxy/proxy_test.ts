import { createHandler } from "./proxy.ts";

const ORIGIN = "http://127.0.0.1:9097";
const LOCAL = "http://127.0.0.1:9098";
const AUTH = `Basic ${btoa("mock-user:mock-password")}`;

function assert(
  condition: unknown,
  message = "Assertion failed",
): asserts condition {
  if (!condition) throw new Error(message);
}

async function withUpstream(
  upstreamHandler: Deno.ServeHandler,
  run: (
    handler: ReturnType<typeof createHandler>,
    upstream: string,
  ) => Promise<void>,
) {
  const server = Deno.serve({
    hostname: "127.0.0.1",
    port: 0,
    onListen: () => {},
  }, upstreamHandler);
  const upstream = `http://127.0.0.1:${server.addr.port}`;
  const handler = createHandler({
    port: 9098,
    upstream,
    pathPrefix: "/dav",
    allowedOrigins: [ORIGIN],
  });
  try {
    await run(handler, upstream);
  } finally {
    await server.shutdown();
  }
}

function request(
  path: string,
  method = "GET",
  body?: BodyInit,
  extraHeaders = {},
): Request {
  return new Request(`${LOCAL}${path}`, {
    method,
    headers: { Origin: ORIGIN, Authorization: AUTH, ...extraHeaders },
    body,
  });
}

Deno.test("preflight is local and rejects unsupported origins, paths, methods, and headers", async () => {
  const handler = createHandler({
    port: 9098,
    upstream: "https://unreachable.invalid",
    pathPrefix: "/dav",
    allowedOrigins: [ORIGIN],
  });
  const response = await handler(
    new Request(`${LOCAL}/dav/`, {
      method: "OPTIONS",
      headers: {
        Origin: ORIGIN,
        "Access-Control-Request-Method": "PROPFIND",
        "Access-Control-Request-Headers": "Authorization, Content-Type, Depth",
      },
    }),
  );
  assert(response.status === 204);
  assert(response.headers.get("access-control-allow-origin") === ORIGIN);
  assert(
    response.headers.get("access-control-allow-methods")?.includes("MKCOL"),
  );
  assert(
    response.headers.get("access-control-allow-headers")?.includes(
      "authorization",
    ),
  );
  assert(response.headers.get("vary")?.includes("Origin"));
  for (
    const [url, method, headers, expected] of [
      [
        `${LOCAL}/dav/`,
        "OPTIONS",
        { Origin: "https://untrusted.example" },
        403,
      ],
      [`${LOCAL}/other/`, "OPTIONS", { Origin: ORIGIN }, 404],
      [`${LOCAL}/dav-other/`, "OPTIONS", { Origin: ORIGIN }, 404],
      [
        "http://untrusted.example:9098/dav/",
        "OPTIONS",
        { Origin: ORIGIN },
        421,
      ],
      [`${LOCAL}/dav/`, "POST", { Origin: ORIGIN }, 405],
      [`${LOCAL}/dav/`, "OPTIONS", {
        Origin: ORIGIN,
        "Access-Control-Request-Headers": "Proxy-Authorization",
      }, 400],
      [`${LOCAL}/dav/`, "OPTIONS", {
        Origin: ORIGIN,
        "Access-Control-Request-Method": "COPY",
      }, 405],
    ] as const
  ) {
    const denied = await handler(new Request(url, { method, headers }));
    assert(denied.status === expected, `${method} ${url}: ${denied.status}`);
    if (headers.Origin !== ORIGIN) {
      assert(!denied.headers.has("access-control-allow-origin"));
    }
    await denied.body?.cancel();
  }
});

Deno.test("PROPFIND preserves encoded paths, auth, depth, XML, and CORS on error responses", async () => {
  const xml =
    '<D:multistatus xmlns:D="DAV:"><D:response><D:href>/dav/books/</D:href></D:response></D:multistatus>';
  await withUpstream(async (incoming) => {
    const url = new URL(incoming.url);
    assert(incoming.headers.get("host") === url.host);
    assert(!incoming.headers.has("cookie"));
    assert(!incoming.headers.has("origin"));
    assert(!incoming.headers.has("referer"));
    if (url.pathname === "/dav/error") {
      return new Response("Unauthorized", { status: 401 });
    }
    assert(url.pathname === "/dav/My%20Books/%E4%B9%A6");
    assert(url.search === "?depth=1");
    assert(incoming.method === "PROPFIND");
    assert(incoming.headers.get("authorization") === AUTH);
    assert(incoming.headers.get("depth") === "1");
    assert(await incoming.text() === "<propfind/>");
    return new Response(xml, {
      status: 207,
      headers: {
        "Content-Type": "application/xml",
        "ETag": '"mock-etag"',
        "Access-Control-Allow-Origin": "https://wrong.example",
        "Set-Cookie": "must-not-reach-browser=1",
      },
    });
  }, async (handler) => {
    const response = await handler(
      request("/dav/My%20Books/%E4%B9%A6?depth=1", "PROPFIND", "<propfind/>", {
        "Content-Type": "application/xml",
        Depth: "1",
        Cookie: "must-not-reach-upstream=1",
        Referer: `${ORIGIN}/user`,
      }),
    );
    assert(response.status === 207);
    assert(response.headers.get("access-control-allow-origin") === ORIGIN);
    assert(
      response.headers.get("access-control-expose-headers")?.includes("ETag"),
    );
    assert(response.headers.get("etag") === '"mock-etag"');
    assert(!response.headers.has("set-cookie"));
    assert(await response.text() === xml);
    const denied = await handler(request("/dav/error"));
    assert(denied.status === 401);
    assert(denied.headers.get("access-control-allow-origin") === ORIGIN);
    await denied.body?.cancel();
  });
});

Deno.test("file operations forward streamed binary bodies and preserve HEAD metadata", async () => {
  const files = new Map<string, ArrayBuffer>();
  const bytes = new Uint8Array(262_144).map((_, index) => index % 251);
  await withUpstream(async (incoming) => {
    assert(incoming.headers.get("authorization") === AUTH);
    const path = new URL(incoming.url).pathname;
    if (incoming.method === "MKCOL") return new Response(null, { status: 201 });
    if (incoming.method === "PUT") {
      files.set(path, await incoming.arrayBuffer());
      return new Response(null, { status: 201 });
    }
    if (incoming.method === "DELETE") {
      assert(incoming.headers.get("depth") === "infinity");
      files.delete(path);
      return new Response(null, { status: 204 });
    }
    const file = files.get(path);
    if (!file) return new Response(null, { status: 404 });
    const headers = {
      "Content-Length": String(file.byteLength),
      "ETag": '"file-etag"',
    };
    return new Response(incoming.method === "HEAD" ? null : file, { headers });
  }, async (handler) => {
    assert((await handler(request("/dav/books", "MKCOL"))).status === 201);
    const stream = new ReadableStream({
      start(controller) {
        for (let start = 0; start < bytes.length; start += 16_384) {
          controller.enqueue(bytes.slice(start, start + 16_384));
        }
        controller.close();
      },
    });
    const uploaded = await handler(
      request("/dav/books/book.epub", "PUT", stream, {
        "Content-Type": "application/octet-stream",
      }),
    );
    assert(uploaded.status === 201);
    const head = await handler(request("/dav/books/book.epub", "HEAD"));
    assert(head.status === 200 && head.body === null);
    assert(head.headers.get("content-length") === String(bytes.length));
    assert(head.headers.get("etag") === '"file-etag"');
    const downloaded = await handler(request("/dav/books/book.epub"));
    const actual = new Uint8Array(await downloaded.arrayBuffer());
    assert(
      actual.length === bytes.length &&
        actual.every((byte, index) => byte === bytes[index]),
    );
    assert(
      (await handler(
        request("/dav/books/book.epub", "DELETE", undefined, {
          Depth: "infinity",
        }),
      )).status === 204,
    );
    assert(
      (await handler(request("/dav/books/book.epub", "HEAD"))).status === 404,
    );
  });
});

Deno.test("redirects stay on the local endpoint and external redirects are rejected", async () => {
  await withUpstream((incoming) => {
    const url = new URL(incoming.url);
    const location = url.pathname === "/dav/elsewhere"
      ? "https://untrusted.example/dav/"
      : url.pathname === "/dav/outside"
      ? "/other/"
      : `${url.origin}/dav/books/?page=2`;
    return new Response(null, { status: 301, headers: { Location: location } });
  }, async (handler) => {
    const response = await handler(request("/dav/books"));
    assert(response.status === 301);
    assert(response.headers.get("location") === `${LOCAL}/dav/books/?page=2`);
    await response.body?.cancel();
    for (const path of ["/dav/elsewhere", "/dav/outside"]) {
      const denied = await handler(request(path));
      assert(denied.status === 502);
      assert(denied.headers.get("access-control-allow-origin") === ORIGIN);
      await denied.body?.cancel();
    }
  });
});

Deno.test("decoded upstream content has no stale compression headers", async () => {
  const content = "Readable WebDAV content ".repeat(100);
  const compressed = await new Response(
    new Blob([content]).stream().pipeThrough(new CompressionStream("gzip")),
  ).arrayBuffer();
  await withUpstream(() =>
    new Response(compressed, {
      headers: {
        "Content-Encoding": "gzip",
        "Content-Length": String(compressed.byteLength),
      },
    }), async (handler) => {
    const response = await handler(request("/dav/compressed"));
    assert(!response.headers.has("content-encoding"));
    assert(!response.headers.has("content-length"));
    assert(await response.text() === content);
  });
});

Deno.test("HTTP MKCOL stays bodyless through directory redirects before a book upload", async () => {
  let sawChunkedMkcol = false;
  let uploaded: ArrayBuffer | undefined;
  await withUpstream(async (incoming) => {
    const url = new URL(incoming.url);
    if (incoming.method === "MKCOL") {
      if (!url.pathname.endsWith("/")) {
        return new Response(null, {
          status: 301,
          headers: { Location: `${url.pathname}/` },
        });
      }
      // Apache mod_dav rejects an unsupported MKCOL request body, even
      // when a chunked transfer contains zero bytes.
      sawChunkedMkcol = incoming.headers.get("transfer-encoding") === "chunked";
      await incoming.body?.cancel();
      return new Response(null, { status: sawChunkedMkcol ? 415 : 201 });
    }
    assert(
      incoming.headers.get("content-length") === "262144",
      "Upload size was lost",
    );
    uploaded = await incoming.arrayBuffer();
    return new Response(null, { status: 201 });
  }, async (_handler, upstream) => {
    const proxy = Deno.serve({
      hostname: "127.0.0.1",
      port: 0,
      onListen: () => {},
    }, (incoming) => handler(incoming));
    const base = `http://127.0.0.1:${proxy.addr.port}`;
    const handler = createHandler({
      port: proxy.addr.port,
      upstream,
      pathPrefix: "/dav",
      allowedOrigins: [ORIGIN],
    });
    try {
      const created = await fetch(`${base}/dav/books`, {
        method: "MKCOL",
        headers: { Origin: ORIGIN, Authorization: AUTH },
      });
      await created.body?.cancel();
      assert(created.status === 201, `MKCOL returned ${created.status}`);
      assert(!sawChunkedMkcol, "A bodyless MKCOL acquired chunked encoding");
      const bytes = new Uint8Array(262_144).map((_, index) => index % 251);
      const put = await fetch(`${base}/dav/books/book.epub`, {
        method: "PUT",
        headers: {
          Origin: ORIGIN,
          Authorization: AUTH,
          "Content-Type": "application/octet-stream",
        },
        body: bytes,
      });
      await put.body?.cancel();
      assert(put.status === 201);
      assert(uploaded?.byteLength === bytes.byteLength);
      assert(
        new Uint8Array(uploaded).every((byte, index) => byte === bytes[index]),
      );
    } finally {
      await proxy.shutdown();
    }
  });
});
