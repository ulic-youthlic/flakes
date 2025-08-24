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
    services.emacs.enable = true;
    programs.doom-emacs = {
      enable = true;
      emacs = pkgs.emacs-pgtk;
      extraPackages =
        emacsPackages: with emacsPackages; [
          melpaPackages.telega
        ];
      extraBinPackages = with pkgs; [
        editor-runtime

        git
        ripgrep
        fd
      ];
      doomDir = ./config;
    };
  };
}
