{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.hardware;
in {
  options = {
    youthlic.hardware = {
      asus = {
        enable = lib.mkEnableOption "asus";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.asus.enable {
      youthlic.programs = {
        asusd.enable = true;
        supergfxd.enable = true;
      };
    })
  ];
}
