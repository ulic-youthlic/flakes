{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
with lib;
pipe
  [
    ./niri.nix
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
    ./vim.nix

    # Nur
    ./nur.nix
  ]
  [
    (map (file: import file args))
    (overlays: (lib.composeManyExtensions overlays) final prev)
  ]
