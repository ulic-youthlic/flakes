{
  pkgs,
  config,
  lib,
  osConfig ? null,
  inputs,
  ...
}: let
  cfg = config.youthlic.programs.niri;
  niri = osConfig.programs.niri.package;
in {
  options = {
    youthlic.programs.niri = {
      enable = lib.mkEnableOption "niri";
      # settings = lib.mkOption {
      #   type = lib.types.attrs;
      # };
      config = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
      };
    };
  };
  config = lib.mkMerge [
    {
      youthlic.programs.niri.enable = osConfig.youthlic.gui.enabled == "niri";
    }
    (
      lib.mkIf cfg.enable {
        home.packages =
          (with pkgs; [
            swaynotificationcenter
            swaybg
            xwayland-satellite
            kdePackages.polkit-kde-agent-1
            wl-clipboard
            cliphist
          ])
          ++ [niri];
        qt = {
          enable = true;
        };
        xdg.portal = {
          configPackages = [niri];
          enable = true;
          extraPortals = lib.mkIf (
            !niri.cargoBuildNoDefaultFeatures || builtins.elem "xdp-gnome-screencast" niri.cargoBuildFeatures
          ) [pkgs.xdg-desktop-portal-gnome];
        };
        xdg.configFile = let
          qtctConf =
            ''
              [Appearance]
              standard_dialogs=xdgdesktopportal
            ''
            + lib.optionalString (config.qt.style ? name) ''
              style=${config.qt.style.name}
            '';
        in {
          "qt5ct/qt5ct.conf" = lib.mkForce {
            text = qtctConf;
          };
          "qt6ct/qt6ct.conf" = lib.mkForce {
            text = qtctConf;
          };
        };
        youthlic.programs = {
          fuzzel.enable = true;
          wluma.enable = true;
          waybar.enable = true;
          swaync.enable = true;
          swaylock.enable = true;
        };
        programs.niri = {
          # settings = cfg.settings;
          config = cfg.config;
          package = niri;
        };
      }
    )
  ];
}
