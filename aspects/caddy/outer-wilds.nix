{ den, ... }:
{
  den.aspects.caddy.outer-wilds = {
    includes = [ den.aspects.caddy ];
    nixos =
      {
        host,
        pkgs,
        ...
      }:
      let
        caddy-cfg = host.caddy;
      in
      {
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
}
