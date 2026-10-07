{ den, ... }:
{
  den.aspects.niri = {
    includes = with den.aspects; [
      gui
      ly
      nautilus
      evince
      swayimg
      seahorse
    ];
    nixos =
      {
        pkgs,
        ...
      }:
      {
        environment = {
          systemPackages = with pkgs; [
            wl-clipboard
            bluez
          ];
        };
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        hardware.bluetooth = {
          enable = true;
        };
        programs = {
          niri = {
            enable = true;
            package = pkgs.niri;
          };
        };
      };
    provides.to-users = {
      includes = with den.aspects; [
        kanshi
        david.noctalia
        ghostty
        zen-browser
        helium
      ];
      homeManager =
        {
          pkgs,
          ...
        }:
        {
          services.gnome-keyring.enable = true;
          wayland.windowManager.niri = {
            enable = true;
            package = pkgs.niri;
            settings = { };
            checkConfig = true;
            systemd = {
              enable = true;
              variables = [ ];
            };
            portalPackage = pkgs.xdg-desktop-portal-gnome;
            xwaylandSatellitePackage = pkgs.xwayland-satellite;
          };
        };
    };
  };
}
