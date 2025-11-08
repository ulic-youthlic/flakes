{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.emacs;
in {
  options = {
    youthlic.programs.emacs = {
      enable = lib.mkEnableOption "emacs";
    };
  };
  config = lib.mkIf cfg.enable {
    services.emacs = {
      enable = true;
      install = true;
      package = with pkgs;
        (emacsPackagesFor emacs-pgtk).emacsWithPackages (
          p:
            with p; [
              vterm
              evil
              gruvbox-theme
            ]
        );
    };
  };
}
