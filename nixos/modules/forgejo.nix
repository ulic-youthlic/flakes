{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.forgejo;
in
{
  options = {
    youthlic.programs.forgejo = {
      enable = lib.mkEnableOption "forgejo";
      domain = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "example.com";
        description = ''
          which domain does the server use
        '';
      };
      sshPort = lib.mkOption {
        type = lib.types.port;
        default = 2222;
      };
      httpPort = lib.mkOption {
        type = lib.types.port;
        default = 8480;
      };
      database = {
        user = lib.mkOption {
          type = lib.types.nonEmptyStr;
          example = "forgejo";
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
      services.forgejo = {
        enable = true;
        lfs = {
          enable = true;
        };
        group = "postgres";
        database = {
          type = "postgres";
          user = cfg.database.user;
          socket = cfg.database.socket;
          createDatabase = false;
        };
        settings = {
          DEFAULT = {
            RUN_MODE = "prod";
          };
          cron = {
            ENABLE = true;
            RUN_AT_START = true;
            SCHEDULE = "@every 24h";
          };
          repository = {
            DEFAULT_PRIVATE = "last";
            DEFAULT_BRANCH = "master";
          };
          service = {
            DISABLE_REGISTRATION = true;
          };
          mailer = {
            ENABLED = true;
            MAILER_TYPE = "sendmail";
            FROM = "do-not-reply@${config.services.forgejo.settings.server.DOMAIN}";
            SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
          };
          other = {
            SHOW_FOOTER_VERSION = false;
          };
          server = {
            PROTOCOL = "http";
            DOMAIN = "${cfg.domain}";
            START_SSH_SERVER = true;
            SSH_PORT = cfg.sshPort;
            HTTP_PORT = cfg.httpPort;
          };
        };
      };
    })
    (
      let
        caddy-cfg = config.youthlic.programs.caddy;
      in
      lib.mkIf (cfg.enable && caddy-cfg.enable) {
        services.caddy.virtualHosts = {
          "forgejo.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              reverse_proxy 127.0.0.1:${cfg.httpPort}
            '';
          };
        };
      }
    )
  ];
}
