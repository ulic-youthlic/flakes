{
  pkgs,
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  cfg = config.youthlic.programs.niri;
  niri = osConfig.programs.niri.package;
in
{
  options = {
    youthlic.programs.niri = {
      enable = lib.mkEnableOption "niri";
      config = lib.mkOption {
        type = lib.types.path;
        example = ./config.kdl;
        description = ''
          the pach to config.kdl
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        swaynotificationcenter
        swaybg
        xwayland-satellite
        kdePackages.polkit-kde-agent-1
        wl-clipboard
        cliphist
      ])
      ++ [ niri ];
    qt = {
      enable = true;
    };
    xdg.portal = {
      configPackages = [ niri ];
      enable = true;
      extraPortals = lib.mkIf (
        !niri.cargoBuildNoDefaultFeatures || builtins.elem "xdp-gnome-screencast" niri.cargoBuildFeatures
      ) [ pkgs.xdg-desktop-portal-gnome ];
    };
    xdg.configFile =
      let
        qtctConf =
          ''
            [Appearance]
            standard_dialogs=xdgdesktopportal
          ''
          + lib.optionalString (config.qt.style ? name) ''
            style=${config.qt.style.name}
          '';
      in
      {
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
      config = builtins.readFile cfg.config;
      package = niri;
    };
  };
}
