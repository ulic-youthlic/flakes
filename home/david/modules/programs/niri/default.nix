{
  config,
  lib,
  inputs,
  pkgs,
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
    };
  };
  config = lib.mkMerge [
    {
      david.programs.niri.enable = config.youthlic.programs.niri.enable;
    }
    (
      lib.mkIf cfg.enable {
        youthlic.programs.niri = {
          config =
            (lib.toList (import ./config.nix (args // {inherit pkgs;})))
            ++ (lib.toList cfg.extraConfig);
        };
        david.programs.wluma.enable = true;
      }
    )
  ];
}
