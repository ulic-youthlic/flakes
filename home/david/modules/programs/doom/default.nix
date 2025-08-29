{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.david.programs.doom;
in
{
  options = {
    david.programs.doom = {
      enable = lib.mkEnableOption "doom";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.emacs.enable = false;
    services.emacs.enable = true;
    programs.doom-emacs = {
      enable = true;
      emacs = pkgs.emacs-pgtk;
      extraPackages =
        ep: with ep; [
          melpaPackages.telega
        ];
      extraBinPackages = with pkgs; [
        editor-runtime

        git
        ripgrep
        fd
        imagemagick
      ];
      doomDir = ./config;
      provideEmacs = true;
    };
  };
}
