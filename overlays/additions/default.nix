{...} @ args: final: prev: let
  inherit (prev) lib;
in
  [
    ./TrackersListCollection.nix
    ./OuterWildsTextAdventure.nix
    ./editor-runtime.nix
    ./radicle-ci-broker.nix
    ./wallpapers.nix
    ./waydroid-script.nix
  ]
  |> map (file: import file args)
  |> (overlays: (lib.composeManyExtensions overlays) final prev)
