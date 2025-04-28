{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.guix;
in {
  options = {
    youthlic.programs.guix = {
      enable = lib.mkEnableOption "guix";
    };
  };
  config = lib.mkIf cfg.enable {
    services.guix = {
      enable = true;
      gc.enable = true;
      publish.enable = true;
    };
  };
}
