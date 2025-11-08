{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.supergfxd;
in {
  options = {
    youthlic.programs.supergfxd = {
      enable = lib.mkEnableOption "supergfxd";
    };
  };
  config = lib.mkIf cfg.enable {
    services.supergfxd = {
      enable = true;
    };
  };
}
