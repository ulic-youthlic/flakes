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
  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      port = 8083;
      environmentFile = "${config.sops.secrets."open-webui_env".path}";
    };
    sops.secrets."open-webui_env" = {
      format = "yaml";
    };
  };
}
