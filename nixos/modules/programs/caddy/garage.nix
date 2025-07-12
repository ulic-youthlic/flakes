{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.caddy.garage;
  caddy-cfg = config.youthlic.programs.caddy;
in
{
  options = {
    youthlic.programs.caddy.garage = {
      enable = lib.mkEnableOption "caddy.garage";
      target = lib.mkOption {
        type = lib.types.str;
        example = "127.0.0.1";
      };
    };
  };
  config = lib.mkIf (cfg.enable && caddy-cfg.enable) {
    services.caddy.virtualHosts = {
      "wallpaper.${caddy-cfg.baseDomain}" = {
        extraConfig = ''
          reverse_proxy ${cfg.target}:8494
        '';
      };
      "s3.${caddy-cfg.baseDomain}" = {
        extraConfig = ''
          reverse_proxy ${cfg.target}:8491
        '';
      };
    };
  };
}
