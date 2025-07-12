{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.programs.doom;
in
{
  options = {
    youthlic.programs.doom = {
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
