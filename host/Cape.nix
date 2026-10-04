{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = { };
      deploy.enable = true;
    };
    aspects.Cape = {
      includes = with den.aspects; [
        net.juicity.server
        net.openssh
        net.tailscale
        server.caddy
        server.caddy.garage
        server.caddy.outer-wilds
        server.caddy.radicle-explorer
        server.forgejo
        server.matrix-tuwunel
        server.miniflux
        server.radicle
        server.rqbit
        server.rustypaste
      ];
      nixos = {
        imports = [ ../_legacy/nixos/configurations/Cape ];
        users = {
          mutableUsers = false;
          users.alice.openssh.authorizedKeys.keyFiles = [ ./Cape/cape.pub ];
        };
        youthlic = {
          containers.interface = "ens3";
          programs = {
            caddy = {
              baseDomain = "youthlic.social";
              garage.target = "100.73.250.25";
            };
            matrix-tuwunel.serverName = "im.youthlic.social";
            rqbit = {
              ratelimitUpload = 0;
              httpHost = "0.0.0.0";
            };
            rustypaste.url = "https://paste.youthlic.social";
          };
        };
      };
    };
  };
}
