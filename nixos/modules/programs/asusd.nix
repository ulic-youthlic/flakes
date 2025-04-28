{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.asusd;
in {
  options = {
    youthlic.programs.asusd = {
      enable = lib.mkEnableOption "asusd";
    };
  };
  config = lib.mkIf cfg.enable {
    services.asusd = {
      enable = true;
    };
  };
}
