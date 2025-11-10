{
  config,
  lib,
  inputs,
  pkgs,
  osConfig ? (throw "Trying to access osConfig, the home-manager module is not being used in the nixos module"),
  options,
  ...
}: let
  cfg = config.david.programs.niri;
in {
  imports = [
    ./config.nix
  ];
  options = {
    david.programs.niri = {
      enable =
        (lib.mkEnableOption "niri")
        // {
          default = osConfig.youthlic.gui.enabled == "niri";
        };
      config = lib.mkOption {
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
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        swaynotificationcenter
        wl-clipboard
        cliphist
        swayimg
        seahorse
      ];
      xdg.configFile = let
        qtctConf = ''
          [Appearance]
          standard_dialogs=xdgdesktopportal
        '';
      in {
        "qt5ct/qt5ct.conf" = {
          text = qtctConf;
        };
        "qt6ct/qt6ct.conf" = {
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
        inherit (cfg) config;
      };
    })
    (lib.mkIf (!cfg.enable) {
      programs.niri = {
        settings = null;
        config = null;
      };
    })
  ];
}
