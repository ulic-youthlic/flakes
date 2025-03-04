{ config, ... }:
{
  sops.secrets."miniflux" = {
  };
  youthlic.containers.miniflux = {
    enable = true;
    interface = "ens3";
    adminCredentialsFile = config.sops.secrets."miniflux".path;
  };
  services.caddy.virtualHosts = {
    "miniflux.${config.youthlic.programs.caddy.baseDomain}" = {
      extraConfig = ''
        reverse_proxy 10.231.137.102:8485
      '';
    };
  };
}
