{
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.niri;
in {
  options = {
    david.programs.niri = {
      enable = lib.mkEnableOption "niri";
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.programs.niri = {
      enable = true;
      config = ./config.kdl;
    };
    david.programs.wluma.enable = true;
  };
}
