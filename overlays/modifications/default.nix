{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
[
  ./spotify.nix
  ./niri.nix
  ./ghostty.nix
  ./juicity.nix
  ./dae.nix
  ./jujutsu.nix
]
|> map (file: import file args)
|> (overlays: (lib.composeManyExtensions overlays) final prev)
