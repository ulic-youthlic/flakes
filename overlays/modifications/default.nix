{ ... }@args:
final: prev:
let
  inherit (prev) lib;
in
with lib;
pipe
  [
    ./radicle-explorer.nix
    ./wshowkeys.nix
    # ./QQ.nix
    ./helix.nix
    ./zulip.nix
    ./nautilus.nix
    ./vim.nix
    ./prismlauncher.nix
    ./niri.nix
    ./xwayland-satellite.nix

    # Nur
    ./nur.nix
  ]
  [
    (map (file: import file args))
    (overlays: (composeManyExtensions overlays) final prev)
  ]
