{ den, ... }:
{
  den.aspects.niri = {
    includes = with den.aspects; [
      gui
      ly
      xdg
    ];
    nixos =
      {
        pkgs,
        ...
      }:
      {
        # Enabled to support trash of nautilus
        services.gvfs.enable = true;
        environment = {
          pathsToLink = [ "share/thumbnailers" ];
          systemPackages = with pkgs; [
            wl-clipboard
            swayimg
            seahorse

            nautilus
            nautilus-open-any-terminal
            libheif
            libheif.out

            bluez
            evince
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
        david.kanshi
        david.noctalia
        ghostty
        david.zen-browser
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
