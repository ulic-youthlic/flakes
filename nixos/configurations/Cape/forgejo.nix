{ config, ... }:
{
  youthlic.containers.forgejo = {
    enable = true;
    domain = "forgejo.youthlic.fun";
    sshPort = 2222;
    httpPort = 8480;
    interface = "ens3";
  };
  networking.firewall.allowedTCPPorts = [ 2222 ];
  services.caddy.virtualHosts = {
    "forgejo.${config.youthlic.programs.caddy.baseDomain}" = {
      extraConfig = ''
        reverse_proxy 10.231.136.102:8480
      '';
    };
  };
}
