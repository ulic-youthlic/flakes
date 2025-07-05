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
in {
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
  wallpapers = callPackage ./wallpapers.nix {};
}
