{...} @ args: final: prev: let
  inherit (prev) lib;
in
  [
    ./TrackersListCollection.nix
    ./OuterWildsTextAdventure.nix
    ./editor-runtime.nix
  ]
  |> map (file: import file args)
  |> (overlays: (lib.composeManyExtensions overlays) final prev)
