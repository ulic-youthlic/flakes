{config, ...}: {
  youthlic.containers.forgejo = {
    enable = true;
    domain = "forgejo.youthlic.fun";
    sshPort = 2222;
    httpPort = 8480;
  };
  networking.firewall.allowedTCPPorts = [2222];
  services.caddy.virtualHosts = {
    "forgejo.${config.youthlic.programs.caddy.baseDomain}" = {
      extraConfig = ''
        reverse_proxy 192.168.111.101:8480
      '';
    };
  };
}
