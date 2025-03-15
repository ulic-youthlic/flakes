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
  ./fix-pwvucontrol.nix
  ./fix-forgejo-lts.nix
]
|> map (file: import file args)
|> (overlays: (lib.composeManyExtensions overlays) final prev)
