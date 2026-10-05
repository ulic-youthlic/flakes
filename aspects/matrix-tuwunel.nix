{
  den.aspects.matrix-tuwunel = {
    nixos =
      {
        lib,
        host,
        ...
      }:
      let
        cfg = host.matrix-tuwunel;
      in
      {
        config = lib.mkMerge [
          {
            sops.secrets.${cfg.sops.secret} = {
              owner = "tuwunel";
              inherit (cfg.sops) path;
            };
            systemd.services.tuwunel.serviceConfig = {
              EnvironmentFile = cfg.sops.path;
            };
            services.matrix-tuwunel = {
              enable = true;
              settings = {
                global = {
                  port = [ 8481 ];
                  address = [
                    "0.0.0.0"
                    "::"
                  ];
                  trusted_servers = [
                    "matrix.org"
                    "mozilla.org"
                    "nichi.co"
                  ];
                  allow_registration = true;
                  server_name = cfg.serverName;
                  new_user_displayname_suffix = "⚡";
                  database_backup_path = "/var/lib/tuwunel/db.back";
                  well_known = {
                    client = "https://${cfg.serverName}";
                    server = "${cfg.serverName}:443";
                  };
                };
              };
            };
          }
          (lib.mkIf (host.caddy.enable or false) {
            services.caddy.virtualHosts = {
              "${cfg.serverName}" = {
                extraConfig = ''
                  reverse_proxy 127.0.0.1:8481
                '';
              };
            };
          })
        ];
      };
  };
}
