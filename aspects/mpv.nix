{ lib, ... }:
{
  den.aspects.mpv.xdg-mime = lib.genAttrs [
    "audio/*"
    "video/*"
    "application/ogg"
    "application/x-ogg"
    "application/mxf"
    "application/sdp"
    "application/smil"
    "application/x-smil"
    "application/streamingmedia"
    "application/x-streamingmedia"
    "application/vnd.rn-realmedia"
    "application/vnd.rn-realmedia-vbr"
    "application/vnd.ms-asf"
    "application/x-matroska"
    "application/x-ogm"
    "application/x-ogm-audio"
    "application/x-ogm-video"
    "application/x-shorten"
    "application/x-mpegurl"
    "application/vnd.apple.mpegurl"
    "application/x-cue"
    "application/x-extension-m4a"
    "application/x-extension-mp4"
  ] (_: [ "mpv.desktop" ]);

  den.aspects.mpv.homeManager =
    {
      pkgs,
      ...
    }:
    {
      config = {
        catppuccin.mpv.flavor = "mocha";
        programs.mpv = {
          enable = true;
          scripts = [
            pkgs.mpvScripts.uosc
            pkgs.mpvScripts.thumbfast
          ];
        };
      };
    };
}
