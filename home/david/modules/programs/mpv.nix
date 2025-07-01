{
  lib,
  config,
  ...
}: let
  cfg = config.david.programs.mpv;
in {
  options = {
    david.programs.mpv = {
      enable = lib.mkEnableOption "mpv";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
