{ config, lib, ... }:
let
  cfg = config.youthlic.containers.forgejo;
in
{
  options = {
    youthlic.containers.forgejo = {
      enable = lib.mkEnableOption "forgejo container";
      domain = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "forgejo.example.com";
      };
      sshPort = lib.mkOption {
        type = lib.types.port;
        default = 2222;
      };
      httpPort = lib.mkOption {
        type = lib.types.port;
        default = 8480;
      };
      interface = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "ens3";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = cfg.interface;
      enableIPv6 = true;
    };
    containers."forgejo" = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.136.1";
      localAddress = "10.231.136.102";
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
          hostPort = 2222;
          protocol = "tcp";
        }
        {
          containerPort = cfg.sshPort;
          hostPort = 2222;
          protocol = "udp";
        }
      ];

      config =
        { lib, ... }:
        {
          imports = [
            ./../forgejo.nix
            ./../postgresql.nix
          ];

          systemd.tmpfiles.rules = [
            "d /var/lib/forgejo 770 forgejo forgejo -"
            "d /var/lib/postgresql 770 postgres postgres -"
          ];

          youthlic.programs = {
            forgejo = {
              enable = true;
              domain = cfg.domain;
              sshPort = cfg.sshPort;
              httpPort = cfg.httpPort;
              database = {
                user = "forgejo";
              };
            };
            postgresql = {
              enable = true;
              database = "forgejo";
              auth_method = "peer";
              version = "17";
            };
          };

          systemd.services.forgejo = {
            wants = [ "postgresql.service" ];
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
            wantedBy = [ "default.target" ];
          };

          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [
                cfg.httpPort
                cfg.sshPort
              ];
              allowedUDPPorts = [
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
}
