{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = den.users.alice;
      deploy.enable = true;
      forgejo = {
        domain = "forgejo.youthlic.social";
        sshPort = 2222;
        httpPort = 8480;
      };
      containers = {
        interface = "ens3";
        bridgeName = "br0";
      };
      caddy = {
        enable = true;
        baseDomain = "youthlic.social";
        garage.target = "100.73.250.25";
      };
      miniflux = {
        domain = "miniflux.youthlic.social";
        sops = {
          secret = "miniflux";
          path = "/run/secrets/miniflux";
        };
      };
      matrix-tuwunel = {
        serverName = "im.youthlic.social";
        sops = {
          secret = "matrix-reg-token";
          path = "/run/secrets/matrix-reg-token";
        };
      };
      radicle-seed = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbQrJNWcWsFncTX4w/hkhz6zPNwHrTjA+6lnq5dmu/s radicle";
        sops = {
          secret = "ssh-private-key/radicle/Cape";
          path = "/run/secrets/ssh-private-key/radicle/Cape";
        };
        domain = "seed.youthlic.social";
      };
      rqbit = {
        ratelimitUpload = 0;
        sops = {
          secret = "rqbit.secrets.env";
          path = "/run/secrets/rqbit.secrets.env";
        };
      };
      rustypaste = {
        url = "https://paste.youthlic.social";
        sops.auth = {
          secret = "rustypaste/auth";
          path = "/run/secrets/rustypaste/auth";
        };
        sops.delete = {
          secret = "rustypaste/delete";
          path = "/run/secrets/rustypaste/delete";
        };
      };
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
          ./Cape/_hardware-configuration.nix
          ./Cape/_networking.nix
        ];
        users = {
          mutableUsers = false;
          users.alice.openssh.authorizedKeys.keyFiles = [ ./Cape/cape.pub ];
        };
        services.rqbit.httpHost = "0.0.0.0";
      };
    };
  };
}
