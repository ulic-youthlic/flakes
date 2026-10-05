{
  den.aspects.caddy = {
    nixos = {
      services.caddy.enable = true;
      networking.firewall.allowedTCPPorts = [ 443 ];
    };
  };
}
