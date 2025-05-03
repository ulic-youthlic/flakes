{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.gui;
in {
  config = lib.mkIf (cfg.enabled == "cosmic") {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver = {
      display = 0;
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}
