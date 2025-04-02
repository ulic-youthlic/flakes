{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.obs;
in
{
  options = {
    youthlic.programs.obs = {
      enable = lib.mkEnableOption "obs";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-source-record
        obs-vaapi
        obs-vkcapture
        obs-webkitgtk
        obs-pipewire-audio-capture
      ];
    };
  };
}
