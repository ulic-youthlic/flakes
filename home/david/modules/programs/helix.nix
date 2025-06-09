{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.david.programs.helix;
in {
  options = {
    david.programs.helix = {
      enable = lib.mkEnableOption "helix";
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        editor-runtime
      ];
    };
  };
}
