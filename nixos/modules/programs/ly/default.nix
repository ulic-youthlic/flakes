{ config, lib, ... }:
let
  cfg = config.youthlic.programs.ly;
in
{
  options = {
    youthlic.programs.ly = {
      enable = lib.mkEnableOption "ly";
    };
  };
  config = lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "dur_file";
        dur_file_path = toString ./blackhole-smooth-240x67.dur;
        full_color = true;
        animation_frame_delay = 5;
        animation_timeout_sec = 0;
      };
    };
  };
}
