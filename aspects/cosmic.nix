{ den, ... }:
{
  # Not used by any host; kept as the alternative to niri.
  den.aspects.cosmic = {
    includes = [ den.aspects.gui ];
    nixos.services = {
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
      displayManager.cosmic-greeter.enable = true;
    };
  };
}
