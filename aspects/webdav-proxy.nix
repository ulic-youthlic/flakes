{
  den.aspects.webdav-proxy.nixos =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:
    let
      cfg = config.youthlic.programs.webdav-proxy;
      upstream = lib.removeSuffix "/" cfg.upstream;
      proxyConfig = builtins.toJSON {
        inherit (cfg) port pathPrefix allowedOrigins;
        inherit upstream;
      };
    in
    {
      options.youthlic.programs.webdav-proxy = {
        package = lib.mkPackageOption pkgs "webdav-proxy" { };
        port = lib.mkOption {
          type = lib.types.port;
          default = 9098;
          description = "Proxy port on 127.0.0.1.";
        };
        upstream = lib.mkOption {
          type = lib.types.str;
          example = "https://toi.teracloud.jp";
          description = "HTTPS origin of the WebDAV server, without a path or credentials.";
        };
        pathPrefix = lib.mkOption {
          type = lib.types.str;
          default = "/dav";
          description = "WebDAV path prefix, preserved when forwarding requests.";
        };
        allowedOrigins = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          example = [ "http://127.0.0.1:9097" ];
          description = "Browser origins allowed to access the proxy.";
        };
      };

      config = {
        assertions = [
          {
            assertion = builtins.match "https://[A-Za-z0-9.-]+(:[0-9]+)?" upstream != null;
            message = "webdav-proxy.upstream must be an HTTPS origin with a hostname and optional port.";
          }
          {
            assertion = builtins.match "/[A-Za-z0-9/_~.%+-]*" cfg.pathPrefix != null;
            message = "webdav-proxy.pathPrefix must be an absolute URL path without a query or fragment.";
          }
          {
            assertion =
              cfg.allowedOrigins != [ ]
              && lib.all (
                origin: builtins.match "https?://[A-Za-z0-9.-]+(:[0-9]+)?" origin != null
              ) cfg.allowedOrigins;
            message = "webdav-proxy.allowedOrigins must contain HTTP(S) origins without paths.";
          }
        ];

        systemd.services.webdav-proxy = {
          description = "Local WebDAV CORS proxy";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          environment.DENO_DIR = "/var/cache/webdav-proxy";
          serviceConfig = {
            ExecStart = utils.escapeSystemdExecArgs [
              (lib.getExe cfg.package)
              proxyConfig
            ];
            DynamicUser = true;
            CacheDirectory = "webdav-proxy";
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
            CapabilityBoundingSet = "";
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
          };
        };
      };
    };
}
