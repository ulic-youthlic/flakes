{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.gui;
in
{
  config = lib.mkIf (cfg.enabled == "kde") {
    stylix.targets.qt.platform = "kde";
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      xserver = {
        enable = true;
        xkb = {
          layout = "cn";
          variant = "";
        };
      };
    };
  };
}
