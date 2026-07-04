{
  lib,
  config,
  ...
}:
let
  cfg = config.youthlic.programs.kdeconnect;
in
{
  options = {
    youthlic.programs.kdeconnect = {
      enable = lib.mkEnableOption "kdeconnect";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      enable = true;
    };
  };
}
