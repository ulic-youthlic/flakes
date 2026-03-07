{...} @ args: final: prev: let
  inherit (prev) lib;
in
  with lib;
    pipe
    [
      ./TrackersListCollection.nix
      ./OuterWildsTextAdventure.nix
      ./editor-runtime.nix
      ./wallpapers.nix
      ./rime-yuhaostar.nix
      ./rime-all.nix
      ./nixvim.nix
      ./doom-emacs.nix
      ./osu-lazer-bin.nix # typochecker: disable-line

      ./pkgsNoCuda.nix
      ./linux-cachyos.nix
    ]
    [
      (map (file: import file args))
      (overlays: (composeManyExtensions overlays) final prev)
    ]
