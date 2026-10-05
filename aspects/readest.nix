{
  den.aspects.readest.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.youthlic.programs.readest;
      caddy-cfg = config.youthlic.programs.caddy;
    in
    {
      options.youthlic.programs.readest = {
        package = lib.mkPackageOption pkgs "readest-web" { };
        denoPackage = lib.mkPackageOption pkgs "deno" { };
        listen = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 3000;
        };
        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Readest runtime settings, such as SITE_URL and SUPABASE_PUBLIC_URL.";
        };
        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Path to a runtime environment file containing Readest credentials.";
        };
      };

      config = lib.mkMerge [
        ({
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
              DENO_DIR = "/var/cache/readest/deno";
            }
            // cfg.environment;
            # Next.js writes caches beside its server files, so run a writable copy.
            preStart = ''
              cp -r --no-preserve=mode ${cfg.package}/. "$RUNTIME_DIRECTORY/"
              mkdir -p "$CACHE_DIRECTORY/next"
              ln -sfn "$CACHE_DIRECTORY/next" "$RUNTIME_DIRECTORY/apps/readest-app/.next/cache"
            '';
            serviceConfig = {
              ExecStart = ''
                ${lib.getExe cfg.denoPackage} run --no-config --no-lock --cached-only --node-modules-dir=manual --no-prompt --allow-read --allow-write=/run/readest,/var/cache/readest,/tmp --allow-env --allow-net --allow-sys --allow-ffi /run/readest/apps/readest-app/server.js
              '';
              WorkingDirectory = "/run/readest";
              RuntimeDirectory = "readest";
              CacheDirectory = "readest";
              EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
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
        })
        (lib.mkIf config.services.caddy.enable {
          services.caddy.virtualHosts."readest.${caddy-cfg.baseDomain}".extraConfig = ''
            reverse_proxy ${cfg.listen}:${toString cfg.port}
          '';
        })
      ];
    };
}
