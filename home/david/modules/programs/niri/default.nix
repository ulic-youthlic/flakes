{
  config,
  lib,
  pkgs,
  inputs,
  ...
} @ args: let
  cfg = config.david.programs.niri;
in {
  options = {
    david.programs.niri = {
      enable = lib.mkEnableOption "niri";
      extraConfig = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
      };
      DISPLAY = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkMerge [
    {
      david.programs.niri.enable = config.youthlic.programs.niri.enable;
    }
    (
      lib.mkIf cfg.enable {
        home.sessionVariables = {
          inherit (cfg) DISPLAY;
        };
        youthlic.programs.niri = {
          # settings = lib.mkMerge [(import ./settings.nix args) cfg.settings];
          config =
            (lib.toList (import ./config.nix (args
              // {
                inherit (cfg) DISPLAY;
              })))
            ++ (lib.toList cfg.extraConfig);
        };
        david.programs.wluma.enable = true;
      }
    )
  ];
}
