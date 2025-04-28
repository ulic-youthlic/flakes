{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.gui;
in {
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
    ];
    xdg = {
      terminal-exec = {
        enable = true;
        settings = {
          default = ["com.mitchellh.ghostty.desktop"];
        };
      };
      mime = {
        enable = true;
        defaultApplications = {
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
          "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
          "x-scheme-handler/unknown" = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
        };
      };
    };
    hardware.bluetooth = {
      enable = true;
    };
    services.xserver = {
      enable = true;
      xkb = {
        layout = "cn";
        variant = "";
      };
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
