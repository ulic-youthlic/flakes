{ den, ... }:
{
  den.aspects.server.caddy.outer-wilds = {
    includes = [ den.aspects.server.caddy ];
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        caddy-cfg = config.youthlic.programs.caddy;
      in
      {
        config = {
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
      };
  };
}
