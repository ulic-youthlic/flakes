{
  inputs,
  stdenv,
  editor-runtime,
  symlinkJoin,
  makeWrapper,
}: let
  inherit (stdenv.hostPlatform) system;
  inherit (inputs) nixpkgs emacs-overlay nix-doom;
  pkgs = import nixpkgs {
    localSystem = {inherit system;};
    overlays = [
      emacs-overlay.overlays.default
      nix-doom.overlays.default
    ];
  };
  emacs = pkgs.emacs-igc-pgtk;
  doom-emacs = pkgs.doomEmacs {
    doomDir = ./config;
    doomLocalDir = "~/.local/share/nix-doom";
    emacs = emacs;
    extraPackages = ep:
      with ep; [
        melpaStablePackages.telega
        melpaPackages.nixos-options
        melpaPackages.scroll-on-jump
        melpaPackages.org-modern
      ];
    extraBinPackages =
      (with pkgs; [
        git
        ripgrep
        fd
      ])
      ++ [
        editor-runtime
      ];
  };
in
  symlinkJoin {
    name = "doom-emacs";
    paths = [doom-emacs];
    inherit (doom-emacs) meta;
    buildInputs = [
      makeWrapper
    ];
    env = {
      ORIGINAL_EMACS = toString emacs;
    };
    postBuild = ''
      wrapProgram $out/bin/doom-emacs \
        --unset EMACSNATIVELOADPATH \
        --unset EMACSLOADPATH \
        --inherit-argv0

      mkdir -p $out/share/applications
      cp ''${ORIGINAL_EMACS}/share/applications/emacs.desktop \
        $out/share/applications/doom-emacs.desktop
      cp -rt $out/share ''${ORIGINAL_EMACS}/share/icons
      substituteInPlace $out/share/applications/doom-emacs.desktop \
        --replace 'Name=Emacs' 'Name=Doom Emacs' \
        --replace 'Exec=emacs' "Exec=$out/bin/doom-emacs" \
        --replace 'StartupWMClass=Emacs' "StartupWMClass=Doom Emacs"
    '';
  }
