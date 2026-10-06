{ inputs, ... }:
{
  den.aspects.spotify.xdg-mime."x-scheme-handler/spotify" = [ "spotify.desktop" ];

  den.aspects.spotify.homeManager =
    {
      pkgs,
      ...
    }:
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
          enabledExtensions = with pkgs.spicePkgs.extensions; [
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
          theme = pkgs.spicePkgs.themes.catppuccin;
          colorScheme = "mocha";
        };
      };
    };
}
