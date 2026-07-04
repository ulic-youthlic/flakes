{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
with lib;
pipe
  [
    ./TrackersListCollection.nix
    ./OuterWildsTextAdventure.nix
    ./editor-runtime.nix
    ./wallpapers.nix
    ./rime-all.nix
    ./iosevka-serif_fixed.nix

    ./pkgsNoCuda.nix
    ./linux-cachyos.nix
  ]
  [
    (map (file: import file args))
    (overlays: (composeManyExtensions overlays) final prev)
  ]
