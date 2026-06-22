{...} @ args: final: prev: let
  inherit (prev) lib;
in
  with lib;
    pipe
    [
      ./niri.nix
      ./radicle-explorer.nix
      ./wshowkeys.nix
      # ./QQ.nix
      ./dae.nix
      ./helix.nix
      ./zulip.nix
      ./nautilus.nix
      ./neovim-nightly.nix
      ./vim.nix
      ./prismlauncher.nix
      ./fix-clash-verge.nix

      # Nur
      ./nur.nix
    ]
    [
      (map (file: import file args))
      (overlays: (composeManyExtensions overlays) final prev)
    ]
