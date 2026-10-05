{ den, ... }:
{
  # Not used by any host; kept as the alternative to niri.
  den.aspects.kde = {
    includes = [ den.aspects.gui ];
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
