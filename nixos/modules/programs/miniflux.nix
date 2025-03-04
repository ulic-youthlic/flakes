{ lib, config, ... }:
let
  cfg = config.youthlic.programs.miniflux;
in
{
  options = {
    youthlic.programs.miniflux = {
      enable = lib.mkEnableOption "miniflux";
      adminCredentialsFile = lib.mkOption {
        type = lib.types.path;
      };
      database = {
        user = lib.mkOption {
          type = lib.types.nonEmptyStr;
          example = "miniflux";
        };
        socket = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "/run/postgresql";
        };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.miniflux = {
        enable = true;
        config = {
          LISTEN_ADDR = "0.0.0.0:8485";
          DATABASE_URL = "user=${cfg.database.user} host=${cfg.database.socket} dbname=miniflux";
          CREATE_ADMIN = 1;
          WATCHDOG = 1;
        };
        createDatabaseLocally = false;
        adminCredentialsFile = cfg.adminCredentialsFile;
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "miniflux.${config.youthlic.programs.caddy.baseDomain}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8485
          '';
        };
      };
    })
  ];
}
