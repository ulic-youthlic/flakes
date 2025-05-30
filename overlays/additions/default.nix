{...} @ args: final: prev: let
  inherit (prev) lib;
in
  [
    ./rime-ice.nix
    ./TrackersListCollection.nix
    ./OuterWildsTextAdventure.nix
  ]
  |> map (file: import file args)
  |> (overlays: (lib.composeManyExtensions overlays) final prev)
