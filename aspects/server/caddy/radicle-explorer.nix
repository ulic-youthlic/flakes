{ den, ... }:
{
  den.aspects.server.caddy.radicle-explorer = {
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
      };
  };
}
