{ den, ... }:
{
  den.aspects.caddy.radicle-explorer = {
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
