{...} @ args: final: prev: let
  inherit (prev) lib;
in
  [
    ./niri.nix
    ./juicity.nix
    ./dae.nix
    ./spotifyx.nix
    ./radicle-explorer.nix
    ./wshowkeys.nix
  ]
  |> map (file: import file args)
  |> (overlays: (lib.composeManyExtensions overlays) final prev)
