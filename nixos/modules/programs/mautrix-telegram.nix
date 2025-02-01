{ config, lib, ... }:
let
  cfg = config.youthlic.programs.mautrix-telegram;
in
{
  options = {
    youthlic.programs.mautrix-telegram = {
      enable = lib.mkEnableOption "mautrix-telegram";
    };
  };
  config =
    let
      conduwuit-cfg = config.youthlic.programs.conduwuit;
      caddy-cfg = config.youthlic.programs.caddy;
    in
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        sops.secrets.matrix-telegram-bot = { };
        services.mautrix-telegram = {
          enable = true;
          environmentFile = "${config.sops.secrets.matrix-telegram-bot.path}";
          settings = {
            bridge = {
              permissions = {
                "*" = "relaybot";
              };
            };
            appservice = {
              address = "http://127.0.0.1:8482";
              hostname = "0.0.0.0";
              port = 8482;
              database = "sqlite:////var/lib/mautrix-telegram/database.db";
              bot_username = "matrix_tg_146bot";
              bot_displayname = "matrix tg bridge";
            };
          };
        };
        nixpkgs.config.permittedInsecurePackages = [
          "olm-3.2.16"
        ];
      })
      (lib.mkIf (cfg.enable && conduwuit-cfg.enable) {
        services.mautrix-telegram = {
          serviceDependencies = [
            "conduwuit.service"
          ];
          settings = {
            bridge = {
              permissions = {
                "${conduwuit-cfg.serverName}" = "full";
                "@youthlic:${conduwuit-cfg.serverName}" = "admin";
              };
            };
            homeserver = {
              domain = conduwuit-cfg.serverName;
              address = "http://127.0.0.1:8481";
            };
          };
        };
      })
    ];
}
