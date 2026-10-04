{
  den.aspects.server.caddy = {
    nixos =
      {
        lib,
        config,
        ...
      }:
      let
        cfg = config.youthlic.programs.caddy;
      in
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
