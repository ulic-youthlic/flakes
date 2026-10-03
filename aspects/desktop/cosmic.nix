{ den, ... }:
{
  # Not used by any host; kept as the alternative to desktop.niri.
  den.aspects.desktop.cosmic = {
    includes = [ den.aspects.desktop.gui ];
    nixos.services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
      displayManager.cosmic-greeter.enable = true;
    };
  };
}
