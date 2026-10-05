{ den, ... }:
{
  den.aspects.caddy.outer-wilds = {
    includes = [ den.aspects.caddy ];
    nixos =
      {
        config,
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
