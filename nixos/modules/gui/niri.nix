{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.gui;
in
{
  options = {
    youthlic.gui.niri = {
    };
  };
  config = lib.mkIf (cfg.enabled == "niri") {
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };
    environment.systemPackages = with pkgs; [
      bluez
      cosmic-files
      kdePackages.qt6ct
      libsForQt5.qt5ct
      xwayland-satellite-unstable
      evince
    ];
    xdg = {
      terminal-exec = {
        enable = true;
        settings = {
          default = [ "Alacritty.desktop" ];
        };
      };
      mime = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [
            "org.gnome.Evince.desktop"
          ];
          "inode/directory" = [
            "com.system76.CosmicFiles.desktop"
          ];
          "x-scheme-handler/about" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
          "x-scheme-handler/ftp" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
          "x-scheme-handler/http" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
          "x-scheme-handler/https" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
          "x-scheme-handler/mailto" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
          "x-scheme-handler/tg" = [ "telegramdesktop.desktop" ];
          "x-scheme-handler/unknown" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
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
