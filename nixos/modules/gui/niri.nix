{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.gui;
in {
  options = {
    youthlic.gui.niri = {
    };
  };
  config = lib.mkIf (cfg.enabled == "niri") {
    # Enabled to support trash of nautilus
    services.gvfs.enable = true;

    systemd.user.services.niri-flake-polkit.serviceConfig.ExecStart = lib.mkForce "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";

    environment = {
      pathsToLink = ["share/thumbnailers"];
      systemPackages = with pkgs; [
        nautilus
        nautilus-open-any-terminal
        libheif
        libheif.out

        bluez
        xwayland-satellite-unstable
        evince
      ];
    };
    xdg = {
      portal = {
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };
      terminal-exec = {
        enable = true;
        settings = {
          default = ["com.mitchellh.ghostty.desktop"];
        };
      };
      mime = let
        browsers = [
          "zen-twilight.desktop"
          "chromium-browser.desktop"
        ];
      in {
        enable = true;
        defaultApplications = {
          "application/pdf" = [
            "org.gnome.Evince.desktop"
          ];
          "inode/directory" = [
            "org.gnome.Nautilus.desktop"
          ];
          "text/html" = browsers;
          "x-scheme-handler/about" = browsers;
          "x-scheme-handler/ftp" = browsers;
          "x-scheme-handler/http" = browsers;
          "x-scheme-handler/https" = browsers;
          "x-scheme-handler/mailto" = browsers;
          "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
          "x-scheme-handler/unknown" = browsers;
          "image/gif" = [
            "swayimg.desktop"
          ];
          "image/jpeg" = [
            "swayimg.desktop"
          ];
          "image/png" = [
            "swayimg.desktop"
          ];
          "image/webp" = [
            "swayimg.desktop"
          ];
        };
      };
    };
    hardware.bluetooth = {
      enable = true;
    };
    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --time --user-menu -r";
          };
        };
        useTextGreeter = true;
      };
    };
    programs = {
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
    };
  };
}
