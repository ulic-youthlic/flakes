{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.clash-verge;
in
{
  options = {
    youthlic.programs.clash-verge = {
      enable = lib.mkEnableOption "clash-verge";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.clash-verge = {
      enable = true;
      autoStart = true;
      tunMode = true;
      serviceMode = true;
    };
  };
}
