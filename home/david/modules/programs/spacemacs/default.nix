{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs emacs-overlay spacemacs;
  inherit (pkgs) system;
  cfg = config.david.programs.spacemacs;
  pkgs' = import nixpkgs {
    localSystem = {inherit system;};
    overlays = [emacs-overlay.overlays.default];
  };
in {
  options = {
    david.programs.spacemacs = {
      enable = lib.mkEnableOption "spacemacs";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.emacs.enable = false;
    xdg.configFile = {
      emacs = {
        source = "${spacemacs}";
        recursive = true;
      };
    };
    programs.emacs = {
      enable = true;
      package = with pkgs';
        (emacsPackagesFor emacs-pgtk).emacsWithPackages (_epkgs: [
          git
          gnutar
          ripgrep
        ]);
    };
    services.emacs = {
      client = {
        enable = true;
      };
      defaultEditor = false;
      enable = true;
      socketActivation.enable = true;
      startWithUserSession = true;
    };
  };
}
