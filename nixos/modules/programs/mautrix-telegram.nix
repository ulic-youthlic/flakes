{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.mautrix-telegram;
in {
  options = {
    youthlic.programs.mautrix-telegram = {
      enable = lib.mkEnableOption "mautrix-telegram";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.youthlic.programs.matrix-tuwunel.enable;
        message = ''
          The bridge bot needs to be registered as appservice for home server. So need enable tuwunel.
        '';
      }
    ];
    sops.secrets.matrix-telegram-bot = {};
    services.mautrix-telegram = {
      enable = true;
      environmentFile = "${config.sops.secrets.matrix-telegram-bot.path}";
      serviceDependencies = ["tuwunel.service"];
      settings = {
        bridge = {
          displayname_template = "{displayname} | Telegram";
          telegram_link_preview = true;
          caption_in_message = true;
          parallel_file_transfer = true;
          animated_sticker = {
            target = "gif";
            convert_from_webm = false;
          };
          animated_emoji = {
            target = "webp";
          };
          permissions = {
            "*" = "relaybot";
          };
        };
        appservice = {
          address = "http://127.0.0.1:8482";
          hostname = "0.0.0.0";
          port = 8482;
          bot_username = "telegram";
          bot_displayname = "Telegram Bridge";
        };
        homeserver = {
          address = "http://127.0.0.1:8481";
          domain = config.youthlic.programs.matrix-tuwunel.serverName;
        };
      };
    };
  };
}
