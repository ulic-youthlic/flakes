{ den, ... }:
{
  den.aspects.miniflux = {
    includes = with den.aspects; [
      containers
      caddy
    ];
    nixos =
      {
        pkgs,
        host,
        ...
      }:
      let
        cfg = {
          httpPort = 8485;
        }
        // host.miniflux;
        containerAddress = "192.168.111.102";
        adminCredentialsFile = cfg.sops.path;
      in
      {
        config = {
          sops.secrets.${cfg.sops.secret}.path = cfg.sops.path;
          services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
            reverse_proxy ${containerAddress}:${toString cfg.httpPort}
          '';
          containers."miniflux" = {
            ephemeral = true;
            autoStart = true;
            privateNetwork = true;
            hostBridge = host.containers.bridgeName;
            localAddress = "${containerAddress}/24";
            bindMounts = {
              "/var/lib/miniflux" = {
                hostPath = "/mnt/containers/miniflux/state";
                isReadOnly = false;
              };
              "/var/lib/postgresql" = {
                hostPath = "/mnt/containers/miniflux/database";
                isReadOnly = false;
              };
              "${adminCredentialsFile}" = {
                isReadOnly = true;
              };
            };

            config = { lib, ... }: {
              nixpkgs.pkgs = pkgs;

              systemd.tmpfiles.rules = [
                "d /var/lib/miniflux 770 miniflux miniflux -"
                "d /var/lib/postgresql 770 postgres postgres -"
                "d /run/secrets 770 root miniflux -"
              ];

              services = {
                miniflux = {
                  enable = true;
                  config = {
                    LISTEN_ADDR = "0.0.0.0:${toString cfg.httpPort}";
                    DATABASE_URL = "user=miniflux host=/run/postgresql dbname=miniflux";
                    CREATE_ADMIN = 1;
                    WATCHDOG = 1;
                    BASE_URL = "https://${cfg.domain}";
                  };
                  createDatabaseLocally = false;
                  inherit adminCredentialsFile;
                };
                postgresql = {
                  enable = true;
                  package = pkgs.postgresql_17;
                  ensureDatabases = [ "miniflux" ];
                  ensureUsers = [
                    {
                      name = "miniflux";
                      ensureDBOwnership = true;
                    }
                  ];
                  authentication = ''
                    #type database DBuser auth-method
                    local sameuser all    peer
                  '';
                };
              };

              systemd.services.miniflux = {
                wants = [ "postgresql.service" ];
                requires = [ "postgresql.service" ];
                after = [ "postgresql.service" ];
                wantedBy = [ "default.target" ];
              };

              networking = {
                defaultGateway = "192.168.111.1";
                firewall = {
                  enable = true;
                  allowedTCPPorts = [ cfg.httpPort ];
                  allowedUDPPorts = [ cfg.httpPort ];
                };
                useHostResolvConf = lib.mkForce false;
              };
              services.resolved.enable = true;
              system.stateVersion = "24.11";
            };
          };
        };
      };
  };
}
