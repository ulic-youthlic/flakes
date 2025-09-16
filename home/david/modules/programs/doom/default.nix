{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.david.programs.doom;

  inherit (inputs) emacs-overlay nixpkgs;
  inherit (pkgs) system;
  pkgs' = import nixpkgs {
    inherit system;
    overlays = [ emacs-overlay.overlays.default ];
  };
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
      emacs = pkgs'.emacs-igc-pgtk;
      extraPackages =
        ep: with ep; [
          melpaPackages.telega
          melpaPackages.nixos-options
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
