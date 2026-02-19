{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.caddy.cinny;
  caddy-cfg = config.youthlic.programs.caddy;
in {
  options = {
    youthlic.programs.caddy.cinny = {
      enable = lib.mkEnableOption "caddy.cinny";
    };
  };
  config = lib.mkIf (cfg.enable && caddy-cfg.enable) {
    services.caddy.virtualHosts = {
      "cinny.${caddy-cfg.baseDomain}" = {
        extraConfig = ''
          root * ${pkgs.cinny}
          encode gzip zstd
          try_files {path} /index.html
          file_server
        '';
      };
    };
  };
}
