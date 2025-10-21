{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
[
  ./niri.nix
  ./dae.nix
  ./spotifyx.nix
  ./radicle-explorer.nix
  ./wshowkeys.nix
  # ./QQ.nix
  ./helix.nix
  ./cliphist.nix
  ./zulip.nix
  ./spotifyd.nix
  ./nautilus.nix
  ./neovim-nightly.nix

  # Nur
  ./nur.nix
]
|> map (file: import file args)
|> (overlays: (lib.composeManyExtensions overlays) final prev)
