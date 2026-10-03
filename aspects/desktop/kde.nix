{ den, ... }:
{
  # Not used by any host; kept as the alternative to desktop.niri.
  den.aspects.desktop.kde = {
    includes = [ den.aspects.desktop.gui ];
    nixos.services = {
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
