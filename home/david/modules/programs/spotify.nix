{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.david.programs.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  options = {
    david.programs.spotify = {
      enable = lib.mkEnableOption "spotify";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.spicetify.enable = false;
    programs.spicetify = {
      enable = true;
      wayland = true;
      windowManagerPatch = true;
      enabledExtensions = with spicePkgs.extensions; [
        sort-play
        allOfArtist
        sleepTimer
        coverAmbience
        beautifulLyrics
        sectionMarker
        playingSource
        adblock
        history
        copyToClipboard
        songStats
        playNext
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
