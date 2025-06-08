{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.ion;
in {
  options = {
    youthlic.programs.ion = {
      enable = lib.mkEnableOption "ion";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ion = {
      enable = true;
    };
  };
}
