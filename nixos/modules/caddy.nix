{ lib, config, ... }:
let
  cfg = config.youthlic.programs.caddy;
in
{
  options = {
    youthlic.programs.caddy = {
      enable = lib.mkEnableOption "caddy";
      baseDomain = lib.mkOption {
        type = lib.types.str;
        example = "youthlic.fun";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };
  };
}
