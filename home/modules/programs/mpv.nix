{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.mpv;
in {
  options = {
    youthlic.programs.mpv = {
      enable = lib.mkEnableOption "mpv";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
