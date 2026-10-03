# TypeScript scripts

Keep TypeScript program sources and their tests here, with a separate directory
for each program. Nix packaging belongs in `overlays/`, and NixOS service
configuration belongs in `nixos/modules/`.

`webdav-proxy/` contains the local WebDAV CORS proxy. Its overlay provides
`pkgs.webdav-proxy`, used by the NixOS module of the same name.

```sh
nix build .#webdav-proxy
nix shell nixpkgs#deno -c deno test --unstable-no-legacy-abort \
  --no-config --no-lock --cached-only \
  --allow-net=127.0.0.1 scripts/ts/webdav-proxy/proxy_test.ts
```
