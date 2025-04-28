{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.swaylock;
in {
  options = {
    youthlic.programs.swaylock = {
      enable = lib.mkEnableOption "swaylock";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
    };
  };
}
