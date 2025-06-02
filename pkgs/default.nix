{
  pkgs,
  inputs,
  ...
}: let
  srcs = pkgs.callPackage ./_sources/generated.nix {};
  callPackage = pkgs.lib.callPackageWith (pkgs // {inherit inputs srcs callPackage;});
in
  {
    pinentry-selector = callPackage ./pinentry-selector.nix {};
    helix = callPackage ./helix {};
    juicity = callPackage ./juicity.nix {};
    rime-ice = callPackage ./rime-ice.nix {};
    dioxionary = callPackage ./dioxionary.nix {};
    spotifyx = callPackage ./spotifyx.nix {};
    radicle-explorer = callPackage ./radicle-explorer {};
    TrackersListCollection = callPackage ./TrackersListCollection.nix {};
    wshowkeys-mao = callPackage ./wshowkeys-mao.nix {};
    OuterWildsTextAdventure = callPackage ./OuterWildsTextAdventure.nix {};
    QQ = callPackage ./QQ.nix {};

    noto-serif-cjk = callPackage ./noto-serif-cjk.nix {};
    noto-sans-cjk = callPackage ./noto-sans-cjk.nix {};
  }
  // (
    let
      firefox-addons = callPackage "${inputs.nur-rycee}/pkgs/firefox-addons/default.nix" {};
    in
      pkgs.lib.genAttrs ["immersive-translate" "tridactyl"] (name: firefox-addons."${name}")
  )
