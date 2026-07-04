{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.david.programs.swaylock;
in
{
  options = {
    david.programs.swaylock = {
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
