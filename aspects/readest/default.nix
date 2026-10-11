{ den, lib, ... }:
{
  den.aspects.readest =
    { host, ... }:
    {
      includes = lib.optional (host.readest.webdavProxy.enable or false) den.aspects.readest.webdav-proxy;
      nixos =
        { lib, pkgs, ... }:
        let
          cfg = {
            package = pkgs.readest-web;
            nodePackage = pkgs.nodejs_24;
          }
          // host.readest;
          caddy-cfg = host.caddy;
        in
        {
          config = lib.mkMerge [
            {
              systemd.services.readest = {
                description = "Readest web app";
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                wantedBy = [ "multi-user.target" ];
                environment = {
                  NODE_ENV = "production";
                  HOSTNAME = cfg.listen;
                  PORT = toString cfg.port;
                  SELF_HOSTED = "true";
                  NEXT_TELEMETRY_DISABLED = "1";
                }
                // {
                  SITE_URL = cfg.origin or "http://${cfg.listen}:${toString cfg.port}";
                };
                # Next.js writes caches beside its server files, so run a writable copy.
                preStart = ''
                  cp -r --no-preserve=mode ${cfg.package}/. "$RUNTIME_DIRECTORY/"
                  mkdir -p "$CACHE_DIRECTORY/next"
                  ln -sfn "$CACHE_DIRECTORY/next" "$RUNTIME_DIRECTORY/apps/readest-app/.next/cache"
                '';
                serviceConfig = {
                  ExecStart = ''
                    ${lib.getExe cfg.nodePackage} /run/readest/apps/readest-app/server.js
                  '';
                  WorkingDirectory = "/run/readest";
                  RuntimeDirectory = "readest";
                  CacheDirectory = "readest";
                  DynamicUser = true;
                  Restart = "on-failure";
                  RestartSec = "5s";
                  NoNewPrivileges = true;
                  PrivateTmp = true;
                  PrivateDevices = true;
                  ProtectSystem = "strict";
                  ProtectHome = true;
                  ProtectKernelTunables = true;
                  ProtectKernelModules = true;
                  ProtectControlGroups = true;
                  RestrictSUIDSGID = true;
                };
              };
            }
            (lib.mkIf (host.caddy.enable or false) {
              services.caddy.virtualHosts."readest.${caddy-cfg.baseDomain}".extraConfig = ''
                reverse_proxy ${cfg.listen}:${toString cfg.port}
              '';
            })
          ];
        };
    };
}
