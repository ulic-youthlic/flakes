{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.programs.caddy.outer-wilds-text-adventure;
  caddy-cfg = config.youthlic.programs.caddy;
in
{
  options = {
    youthlic.programs.caddy.outer-wilds-text-adventure = {
      enable = lib.mkEnableOption "caddy.OuterWildsTextAdventure";
    };
  };
  config = lib.mkIf (cfg.enable && caddy-cfg.enable) {
    services.caddy.virtualHosts = {
      "outer-wilds.${caddy-cfg.baseDomain}" = {
        extraConfig = ''
          root * ${pkgs.OuterWildsTextAdventure}
          encode zstd gzip
          try_files {path} /index.html
          file_server
        '';
      };
    };
  };
}
