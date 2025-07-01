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
    stylix.targets.helix.enable = false;
    programs.helix.settings = {
      theme = "gruvbox_dark_hard";
    };
    youthlic.programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        editor-runtime
      ];
    };
  };
}
