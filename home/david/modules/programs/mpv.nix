{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.david.programs.mpv;
in
{
  options = {
    david.programs.mpv = {
      enable = lib.mkEnableOption "mpv";
    };
  };
  config = lib.mkIf cfg.enable {
    catppuccin.mpv.flavor = "mocha";
    programs.mpv = {
      enable = true;
      scripts = [
        pkgs.mpvScripts.uosc
        pkgs.mpvScripts.thumbfast
      ];
    };
  };
}
