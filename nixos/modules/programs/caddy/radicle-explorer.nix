{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.caddy.radicle-explorer;
  caddy-cfg = config.youthlic.programs.caddy;
in {
  options = {
    youthlic.programs.caddy.radicle-explorer = {
      enable = lib.mkEnableOption "caddy.radicle-explorer";
    };
  };
  config = lib.mkIf (cfg.enable && caddy-cfg.enable) {
    services.caddy.virtualHosts = {
      "radicle.${caddy-cfg.baseDomain}" = {
        extraConfig = ''
          root * ${pkgs.radicle-explorer}
          encode zstd gzip
          try_files {path} /index.html
          file_server
        '';
      };
    };
  };
}
