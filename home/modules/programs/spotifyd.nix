{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.spotifyd;
in {
  options = {
    youthlic.programs.spotifyd = {
      enable = lib.mkEnableOption "spotifyd";
    };
  };
  config = lib.mkIf cfg.enable {
    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          device_type = "computer";
          use_mpris = true;
          backend = "pulseaudio";
          bitrate = 320;
          autoplay = false;
        };
      };
    };
  };
}
