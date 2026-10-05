{ den, ... }:
{
  den.aspects.caddy.garage = {
    includes = [ den.aspects.caddy ];
    nixos =
      {
        host,
        ...
      }:
      let
        caddy-cfg = host.caddy;
        cfg = caddy-cfg.garage;
      in
      {
        services.caddy.virtualHosts = {
          "wallpaper.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              reverse_proxy ${cfg.target}:8494
            '';
          };
          "s3.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              reverse_proxy ${cfg.target}:8491
            '';
          };
          "share.${caddy-cfg.baseDomain}" = {
            extraConfig = ''
              reverse_proxy ${cfg.target}:8494
            '';
          };
        };
      };
  };
}
