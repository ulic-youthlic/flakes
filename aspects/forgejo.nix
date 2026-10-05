{ den, ... }:
{
  den.aspects.forgejo = {
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
        cfg = host.forgejo;
        containerAddress = "192.168.111.101";
      in
      {
        networking.firewall.allowedTCPPorts = [ cfg.sshPort ];
        services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
          reverse_proxy ${containerAddress}:${toString cfg.httpPort}
        '';

        containers."forgejo" = {
          ephemeral = true;
          autoStart = true;
          privateNetwork = true;
          hostBridge = host.containers.bridgeName;
          localAddress = "${containerAddress}/24";
          bindMounts = {
            "/var/lib/forgejo" = {
              hostPath = "/mnt/containers/forgejo/state";
              isReadOnly = false;
            };
            "/var/lib/postgresql" = {
              hostPath = "/mnt/containers/forgejo/dataset";
              isReadOnly = false;
            };
          };
          forwardPorts = [
            {
              containerPort = cfg.sshPort;
              hostPort = cfg.sshPort;
              protocol = "tcp";
            }
          ];

          config = { lib, ... }: {
            nixpkgs.pkgs = pkgs;

            systemd.tmpfiles.rules = [
              "d /var/lib/forgejo 770 forgejo forgejo -"
              "d /var/lib/postgresql 770 postgres postgres -"
            ];

            services = {
              forgejo = {
                enable = true;
                lfs.enable = true;
                group = "postgres";
                database = {
                  type = "postgres";
                  user = "forgejo";
                  socket = "/run/postgresql";
                  createDatabase = false;
                };
                settings = {
                  DEFAULT.RUN_MODE = "prod";
                  cron = {
                    ENABLE = true;
                    RUN_AT_START = true;
                    SCHEDULE = "@every 24h";
                  };
                  repository = {
                    DEFAULT_PRIVATE = "last";
                    DEFAULT_BRANCH = "master";
                    DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
                  };
                  service.DISABLE_REGISTRATION = true;
                  mailer = {
                    ENABLED = true;
                    PROTOCOL = "sendmail";
                    FROM = "do-not-reply@${cfg.domain}";
                    SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
                  };
                  other.SHOW_FOOTER_VERSION = false;
                  server = {
                    PROTOCOL = "http";
                    DOMAIN = cfg.domain;
                    START_SSH_SERVER = true;
                    SSH_PORT = cfg.sshPort;
                    SSH_LISTEN_PORT = cfg.sshPort;
                    HTTP_PORT = cfg.httpPort;
                    ROOT_URL = "https://${cfg.domain}";
                  };
                };
              };
              postgresql = {
                enable = true;
                package = pkgs.postgresql_17;
                ensureDatabases = [ "forgejo" ];
                ensureUsers = [
                  {
                    name = "forgejo";
                    ensureDBOwnership = true;
                  }
                ];
                authentication = ''
                  #type database DBuser auth-method
                  local sameuser all    peer
                '';
              };
            };

            systemd.services.forgejo = {
              wants = [ "postgresql.service" ];
              requires = [ "postgresql.service" ];
              after = [ "postgresql.service" ];
              wantedBy = [ "default.target" ];
            };

            networking = {
              defaultGateway = "192.168.111.1";
              firewall = {
                enable = true;
                allowedTCPPorts = [
                  cfg.httpPort
                  cfg.sshPort
                ];
              };
              useHostResolvConf = lib.mkForce false;
            };
            services.resolved.enable = true;
            system.stateVersion = "24.11";
          };
        };
      };
  };
}
