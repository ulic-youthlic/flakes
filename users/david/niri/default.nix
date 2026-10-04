{ den, ... }:
{
  den.aspects.david.niri = {
    includes = with den.aspects; [
      david.kanshi
      david.noctalia
      # _config.nix launches zen-browser as niri's default browser.
      david.zen-browser
      desktop.niri
    ];
    homeManager =
      {
        config,
        lib,
        pkgs,
        kdl,
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
          ./_config.nix
        ];
        options = {
          david.programs.niri = {
            config = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              apply = kdl.formats.v1;
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
          ({
            assertions = [
              {
                assertion = lib.strings.isStorePath (cfg.configHelper.validated-config-for cfg.config);
                message = "david.programs.niri.config must pass validation of wayland.windowManager.niri.package";
              }
            ];
            david.programs.niri.config = lib.mkAfter [
              (kdl.dsl.n "include" (toString config.david.programs.noctalia.niriExtraConfig))
            ];
            home.packages = with pkgs; [
              wl-clipboard
              swayimg
              seahorse
            ];
            services.gnome-keyring.enable = true;
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
      };
  };
}
