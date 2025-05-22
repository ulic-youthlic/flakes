{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.wshowkeys;
in {
  options = {
    youthlic.programs.wshowkeys = {
      enable = lib.mkEnableOption "wshowkeys";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.wshowkeys.enable = true;
  };
}
