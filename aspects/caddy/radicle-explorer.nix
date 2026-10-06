{ den, ... }:
{
  den.aspects.caddy.radicle-explorer = {
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
          "radicle.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              encode zstd gzip
              handle {
                root * ${pkgs.radicle-explorer}
                try_files {path} /index.html
                file_server
              }
            '';
          };
        };
      };
  };
}
