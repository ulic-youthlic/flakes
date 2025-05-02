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
      extraConfig = lib.mkOption {
        type = lib.types.str;
      };
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
    services = {
      greetd = let
        niriConfig = pkgs.writeText "greetd-niri-config.kdl" (''
            binds {}
            hotkey-overlay {
              skip-at-startup
            }
            gestures {
              hot-corners {
                off
              }
            }
            spawn-at-startup "${lib.getExe pkgs.swaybg}" "-i" "${config.stylix.image}"
          ''
          + config.youthlic.gui.niri.extraConfig);
      in {
        enable = true;
        settings = {
          default_session = {
            command = "env GTK_USE_PORTAL=0 GDK_DEBUG=no-portals ${lib.getExe' config.programs.niri.package "niri"} --config ${niriConfig} -- ${lib.getExe config.programs.regreet.package}";
          };
        };
      };
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
        # displayManager.gdm = {
        #   enable = true;
        #   wayland = true;
        # };
      };
    };
    programs = {
      regreet = {
        enable = true;
      };
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
    };
  };
}
