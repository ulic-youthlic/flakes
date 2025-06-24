{
  inputs,
  rootPath,
  callPackages,
  lib,
  pkgs,
  ...
}: let
  srcs = callPackages ./_sources/generated.nix {};
  callPackage = lib.callPackageWith (pkgs // {inherit inputs srcs callPackage rootPath;});
in
  {
    pinentry-selector = callPackage ./pinentry-selector.nix {};
    helix = callPackage ./helix {};
    juicity = callPackage ./juicity.nix {};
    spotifyx = callPackage ./spotifyx.nix {};
    radicle-explorer = callPackage ./radicle-explorer.nix {};
    TrackersListCollection = callPackage ./TrackersListCollection.nix {};
    wshowkeys-mao = callPackage ./wshowkeys-mao.nix {};
    OuterWildsTextAdventure = callPackage ./OuterWildsTextAdventure.nix {};
    QQ = callPackage ./QQ.nix {};
    editor-runtime = callPackage ./editor-runtime.nix {};
    cliphist = callPackage ./cliphist.nix {};
    radicle-ci-broker = callPackage ./radicle-ci-broker.nix {};

    noto-serif-cjk = callPackage ./noto-serif-cjk.nix {};
    noto-sans-cjk = callPackage ./noto-sans-cjk.nix {};
  }
  // (
    let
      firefox-addons = callPackage "${inputs.nur-rycee}/pkgs/firefox-addons/default.nix" {};
    in
      lib.genAttrs ["immersive-translate" "tridactyl" "redirector"] (name: firefox-addons."${name}")
  )
