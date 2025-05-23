{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.gui;
in {
  config = lib.mkIf (cfg.enabled == "kde") {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
      };
    };
  };
}
