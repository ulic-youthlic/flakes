{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.yazi;
in {
  options = {
    youthlic.programs.yazi = {
      enable = lib.mkEnableOption "yazi";
    };
  };
  config = {
    programs.yazi = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
