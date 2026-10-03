{
  lib,
  writeShellApplication,
  deno,
  jq,
}:
writeShellApplication {
  name = "webdav-proxy";
  runtimeInputs = [ jq ];
  text = ''
    if [[ $# -ne 1 ]]; then
      printf 'Usage: webdav-proxy JSON_CONFIG\n' >&2
      exit 2
    fi

    proxy_network=$(jq -er '
      .port as $port
      | select($port | type == "number" and floor == . and . >= 1 and . <= 65535)
      | .upstream
      | capture("^https://(?<host>[A-Za-z0-9.-]+)(:(?<port>[0-9]+))?/?$")
      | "127.0.0.1:\($port),\(.host):\(.port // "443")"
    ' <<< "$1")

    exec ${lib.getExe deno} run \
      --no-config --no-lock --cached-only --no-remote --no-prompt \
      --allow-net="$proxy_network" \
      ${../../scripts/ts/webdav-proxy/proxy.ts} "$1"
  '';
  meta = {
    description = "Local WebDAV CORS proxy running on Deno";
    platforms = lib.platforms.unix;
    mainProgram = "webdav-proxy";
  };
}
