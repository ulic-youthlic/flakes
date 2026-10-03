{ inputs, ... }:
{
  den.aspects.david.spotify.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      # Keyed so a second import into the same home is deduplicated.
      imports = [
        {
          key = "inputs:spicetify-nix/homeManagerModules.spicetify";
          imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];
        }
      ];
      config = {
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
    };
}
