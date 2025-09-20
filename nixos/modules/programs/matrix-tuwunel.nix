{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.matrix-tuwunel;
in
{
  options = {
    youthlic.programs.matrix-tuwunel = {
      enable = lib.mkEnableOption "tuwunel";
      serverName = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "example.com";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops.secrets."matrix-reg-token" = {
        owner = "tuwunel";
      };
      systemd.services.tuwunel.serviceConfig = {
        EnvironmentFile = "${config.sops.secrets.matrix-reg-token.path}";
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
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "${cfg.serverName}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8481
          '';
        };
      };
    })
  ];
}
