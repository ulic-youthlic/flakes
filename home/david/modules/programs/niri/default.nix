{
  config,
  lib,
  pkgs,
  osConfig ? (
    throw "Trying to access osConfig, the home-manager module is not being used in the nixos module"
  ),
  ...
}:
let
  cfg = config.david.programs.niri;
in
{
  imports = [
    ./config.nix
  ];
  options = {
    david.programs.niri = {
      enable = (lib.mkEnableOption "niri") // {
        default = osConfig.youthlic.gui.enabled == "niri";
      };
      config = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        apply = lib.nix-kdl.formats.v1;
      };
      configHelper = lib.mkOption {
        type = lib.types.anything;
        default = {
          validated-config-for =
            configuration:
            pkgs.runCommand "config.kdl"
              {
                inherit configuration;
                passAsFile = [ "configuration" ];
                buildInputs = [ config.wayland.windowManager.niri.package ];
              }
              #bash
              ''
                niri validate -c $configurationPath
                cp $configurationPath $out
              '';
        };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.strings.isStorePath (cfg.configHelper.validated-config-for cfg.config);
          message = "david.programs.niri.config must pass validation of wayland.windowManager.niri.package";
        }
      ];
      david.programs.niri.config = lib.mkAfter [
        (lib.nix-kdl.dsl.n "include" (toString config.david.programs.noctalia.niriExtraConfig))
      ];
      home.packages = with pkgs; [
        wl-clipboard
        swayimg
        seahorse
      ];
      services.gnome-keyring.enable = true;
      xdg.configFile =
        let
          qtctConf = ''
            [Appearance]
            standard_dialogs=xdgdesktopportal
          '';
        in
        {
          "qt5ct/qt5ct.conf" = {
            text = qtctConf;
          };
          "qt6ct/qt6ct.conf" = {
            text = qtctConf;
          };
        };
      david.programs = {
        kanshi.enable = true;
        noctalia.enable = true;
      };
      wayland.windowManager.niri = {
        enable = true;
        package = osConfig.programs.niri.package;
        settings = { };
        extraConfig = cfg.config;
        checkConfig = true;
        systemd = {
          enable = true;
          variables = [ ];
        };
        portalPackage = pkgs.xdg-desktop-portal-gnome;
        xwaylandSatellitePackage = pkgs.xwayland-satellite;
      };
    })
  ];
}
