{ config, lib, ... }:
let
  cfg = config.youthlic.programs.open-webui;
in
{
  options = {
    youthlic.programs.open-webui = {
      enable = lib.mkEnableOption "open-webui";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.open-webui = {
        enable = true;
        port = 8083;
        environmentFile = "${config.sops.secrets."open-webui_env".path}";
      };
      sops.secrets."open-webui_env" = {
        format = "yaml";
      };
    })
    (
      let
        caddy-cfg = config.youthlic.programs.caddy;
      in
      lib.mkIf (cfg.enable && caddy-cfg.enable) {
        services.caddy.virtualHosts = {
          "open-webui.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              reverse_proxy 127.0.0.1:8083
            '';
          };
        };
      }
    )
  ];
}
