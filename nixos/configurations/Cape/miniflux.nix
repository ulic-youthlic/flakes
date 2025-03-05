{ config, ... }:
{
  sops.secrets."miniflux" = {
  };
  youthlic.containers.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets."miniflux".path;
  };
  services.caddy.virtualHosts = {
    "miniflux.${config.youthlic.programs.caddy.baseDomain}" = {
      extraConfig = ''
        reverse_proxy 192.168.111.102:8485
      '';
    };
  };
}
