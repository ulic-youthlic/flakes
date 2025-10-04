{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
[
  ./TrackersListCollection.nix
  ./OuterWildsTextAdventure.nix
  ./editor-runtime.nix
  ./radicle-ci-broker.nix
  ./wallpapers.nix
  ./rime-yuhaostar.nix
  ./nixvim.nix
  ./doom-emacs.nix

  ./pkgsNoCuda.nix
]
|> map (file: import file args)
|> (overlays: (lib.composeManyExtensions overlays) final prev)
