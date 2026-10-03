# Readest web app

`pkgs.readest-web` builds the unmodified `AndyScarlet233/readest` fork using its
`BUILD_STANDALONE=true` configuration. The package includes the Next.js server,
traced dependencies, public assets, and static assets.

```sh
nix build .#readest-web
```

Enable the Deno service with the repo's NixOS module:

```nix
youthlic.programs.readest = {
  enable = true;
  port = 3000;
  environment.SITE_URL = "https://readest.example.com";
  environmentFile = "/run/secrets/readest-env";
};
```

The service listens on localhost by default. When `youthlic.programs.caddy` is
enabled, it also configures `readest.<baseDomain>` as a reverse proxy. Enable the
module on whichever host should serve the app.

Configure Supabase and object storage through the runtime environment or the
environment file for authentication and cloud sync; this module runs the web app
only. See the fork's `docker/.env.example` for the available settings. Keep secrets
in the environment file, outside the Nix store.

For local use on port 9097, set:

```nix
youthlic.programs.readest = {
  enable = true;
  port = 9097;
  environment.SITE_URL = "http://127.0.0.1:9097";
};
```

`SITE_URL` sets the production login callback to
`http://127.0.0.1:9097/auth/callback` and routes client API requests to the local
server. Without it, the app defaults to `https://web.readest.com`. Rebuild and
switch the NixOS configuration, then reload the page to load the runtime setting.

OAuth, confirmation emails, magic links, and password reset links also require
the callback URL to be allowed by the Supabase auth backend. The app defaults to
Readest's official Supabase backend, whose redirect allowlist is controlled by its
operator. Existing-account email/password sign-in uses `signInWithPassword` and
does not require a callback, so it can stay on the local app. For an independently
configured backend, set `SUPABASE_PUBLIC_URL` and `SUPABASE_ANON_KEY`, then add the
local callback in Supabase's Authentication URL Configuration (or
`ADDITIONAL_REDIRECT_URLS` for the fork's Docker deployment). The local server's
cloud APIs need the corresponding backend and storage settings as well.

The web app connects to WebDAV directly from the browser; those requests do not
pass through the Deno service or appear in its journal. The WebDAV endpoint must
support CORS for the app's origin, including an unauthenticated `OPTIONS`
preflight that allows `PROPFIND` and the `Authorization`, `Content-Type`, and
`Depth` headers. File sync also needs the other WebDAV methods and headers used
by the client. Running the app server with Deno does not remove this browser
requirement. If the provider does not support CORS, use a local reverse proxy to
the fixed WebDAV endpoint with suitable CORS headers, or serve that proxy under
the same origin as Readest and enter its URL in the WebDAV form. The native app
uses Tauri's HTTP client and can connect without browser CORS support.

For Teracloud, enable the separate Deno proxy:

```nix
youthlic.programs.webdav-proxy = {
  enable = true;
  port = 9098;
  upstream = "https://toi.teracloud.jp";
  pathPrefix = "/dav";
  allowedOrigins = [ "http://127.0.0.1:9097" ];
};
```

This starts `webdav-proxy.service`, listening only on `127.0.0.1:9098`. It allows
browser requests from the configured origin, handles preflight locally, and
forwards WebDAV requests and credentials to the fixed HTTPS upstream. It
preserves `/dav/` paths and streams file transfers. The proxy does not store
passwords, enable Caddy, or open firewall ports. Request logs contain methods,
statuses, and timing, without headers, query parameters, or bodies.

Apply the configuration with `just switch`, then enter these Readest WebDAV
settings:

| Field          | Value                          |
| -------------- | ------------------------------ |
| Server URL     | `http://127.0.0.1:9098/dav/`   |
| Root directory | `/`                            |
| Username       | Your Teracloud WebDAV username |
| Password       | Your Teracloud WebDAV password |

Use the same `127.0.0.1` address when opening Readest; `localhost` is a different
browser origin unless explicitly added to `allowedOrigins`. Changing the proxy
URL fixes CORS; it does not validate the account's credentials.

When using the original Teracloud URL on Android and the proxy URL in the web
app, disable settings sync on the web instance before restoring either URL:

1. Open **User → Manage Sync** in the web app.
2. Turn off **Dictionaries**, then **App settings**. Dictionaries must be off
   before the App settings toggle can be changed.
3. Reload the web app, then set its WebDAV Server URL to
   `http://127.0.0.1:9098/dav/` and reconnect.
4. Restore `https://toi.teracloud.jp/dav/` on Android if it was overwritten.

The fork includes `webdav.serverUrl` in app-settings sync, so disabling
**Credentials** alone does not prevent URL conflicts. These category toggles
are local in the pinned fork. Keep App settings and Dictionaries sync off on
the web instance while it uses a different URL. This also stops other app
settings and imported dictionaries from syncing to or from that instance;
WebDAV books, reading progress, and annotations can remain enabled. The Readest
source remains unmodified.

```sh
systemctl status webdav-proxy.service
journalctl -u webdav-proxy.service -f
```

If the journal shows `MKCOL` returning `415` and no subsequent `PUT`, update
the proxy and run `just switch`. The proxy keeps empty directory-creation
requests bodyless to avoid Apache WebDAV's rejection of chunked empty bodies.
It preserves known upload lengths when streaming book files. Its Deno launcher
also disables legacy request-signal abort behavior so successful requests do
not abort streamed responses.

The proxy source and tests live in `scripts/ts/webdav-proxy/`. Its overlay in
`overlays/webdav-proxy/` provides `pkgs.webdav-proxy`; the NixOS module launches
that package. The package handles Deno startup and restricts network permissions
to the configured localhost port and upstream. It has no external JavaScript
dependencies. Build it independently or run its forwarding and CORS checks
against a temporary local mock server:

```sh
nix build .#webdav-proxy
nix shell nixpkgs#deno -c deno test --unstable-no-legacy-abort \
  --no-config --no-lock --cached-only \
  --allow-net=127.0.0.1 scripts/ts/webdav-proxy/proxy_test.ts
```

Source updates use `nvfetcher --filter '^readest$'`. When the lockfile changes,
regenerate `pnpmDeps.hash` in `package.nix` by setting it to `lib.fakeHash`, building,
and copying the reported hash.
