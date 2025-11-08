{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.containers.forgejo;
in {
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
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.containers.enable = true;
    containers."forgejo" = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostBridge = "${config.youthlic.containers.bridgeName}";
      localAddress = "192.168.111.101/24";
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

      config = {lib, ...}: {
        imports = [
          ./../programs/forgejo.nix
          ./../programs/postgresql.nix
        ];

        nixpkgs.pkgs = pkgs;

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
          wants = ["postgresql.service"];
          requires = ["postgresql.service"];
          after = ["postgresql.service"];
          wantedBy = ["default.target"];
        };

        networking = {
          defaultGateway = "192.168.111.1";
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
