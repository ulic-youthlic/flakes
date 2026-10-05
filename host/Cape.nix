{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = den.users.alice;
      deploy.enable = true;
    };
    aspects.Cape = {
      includes = with den.aspects; [
        juicity.server
        openssh
        tailscale
        caddy
        caddy.garage
        caddy.outer-wilds
        caddy.radicle-explorer
        forgejo
        matrix-tuwunel
        miniflux
        radicle-seed
        rqbit
        rustypaste
      ];
      nixos = {
        imports = [
          ./Cape/_configuration.nix
          ./Cape/_disko-config.nix
          ./Cape/_forgejo.nix
          ./Cape/_hardware-configuration.nix
          ./Cape/_miniflux.nix
          ./Cape/_networking.nix
          ./Cape/_radicle.nix
        ];
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
