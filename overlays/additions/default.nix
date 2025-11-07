{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
[
  ./TrackersListCollection.nix
  ./OuterWildsTextAdventure.nix
  ./editor-runtime.nix
  ./wallpapers.nix
  ./rime-yuhaostar.nix
  ./rime-all.nix
  ./nixvim.nix
  ./doom-emacs.nix
  ./osu-lazer-bin.nix # typochecker: disable-line

  ./pkgsNoCuda.nix
]
|> map (file: import file args)
|> (overlays: (lib.composeManyExtensions overlays) final prev)
