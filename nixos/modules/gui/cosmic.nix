{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.gui;
in {
  config = lib.mkIf (cfg.enabled == "cosmic") {
    services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
      displayManager.cosmic-greeter.enable = true;
    };
  };
}
