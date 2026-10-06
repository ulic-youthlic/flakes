{ den, ... }:
{
  den.aspects.caddy.radicle-seed-assets = {
    includes = [ den.aspects.caddy ];
    nixos =
      { host, ... }:
      {
        services.caddy.virtualHosts."radicle.${host.caddy.baseDomain}".extraConfig = ''
          @radicleSeedAssets path /images/youthlic-seed-header.png /images/youthlic-seed-avatar.jpg
          handle @radicleSeedAssets {
            root * ${../../assets/radicle-seed}
            file_server
          }
        '';
      };
  };
}
