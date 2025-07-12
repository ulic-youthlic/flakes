{
  config,
  lib,
  inputs,
  pkgs,
  osConfig ? null,
  options,
  ...
}@args:
let
  cfg = config.david.programs.niri;
  niri = osConfig.programs.niri.package;
in
{
  options = {
    david.programs.niri = {
      enable = lib.mkEnableOption "niri";
      extraConfig = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
      };
      wluma.extraSettings = lib.mkOption {
        inherit (options.david.programs.wluma.extraSettings) type;
      };
      waybar = {
        template = lib.mkOption {
          readOnly = true;
          type = lib.types.anything;
          default = config.david.programs.waybar.template;
        };
        helper = lib.mkOption {
          readOnly = true;
          type = lib.types.anything;
          default = config.david.programs.waybar.helper;
        };
        settings = lib.mkOption {
          inherit (options.david.programs.waybar.settings) type;
        };
      };
    };
  };
  config = lib.mkMerge [
    {
      david.programs.niri.enable = osConfig.youthlic.gui.enabled == "niri";
    }
    (lib.mkIf cfg.enable {
      home.packages =
        (with pkgs; [
          swaynotificationcenter
          kdePackages.polkit-kde-agent-1
          wl-clipboard
          cliphist
          swayimg
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
          qtctConf = ''
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
      david.programs = {
        fuzzel.enable = true;
        waybar = {
          enable = true;
          inherit (cfg.waybar) settings;
        };
        wluma = {
          enable = true;
          inherit (cfg.wluma) extraSettings;
        };
        swaync.enable = true;
        swaylock.enable = true;
        waypaper.enable = true;
        kanshi.enable = true;
      };
      programs.niri = {
        config =
          (lib.toList (import ./config.nix (args // { inherit pkgs; }))) ++ (lib.toList cfg.extraConfig);
        package = niri;
      };
    })
  ];
}
