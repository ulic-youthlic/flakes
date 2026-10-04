{
  den.aspects.server.caddy = {
    nixos =
      {
        lib,
        ...
      }:
      {
        options = {
          youthlic.programs.caddy = {
            baseDomain = lib.mkOption {
              type = lib.types.str;
              example = "youthlic.social";
            };
          };
        };
        config = {
          services.caddy = {
            enable = true;
          };
          networking.firewall = {
            allowedTCPPorts = [ 443 ];
          };
        };
      };
  };
}
