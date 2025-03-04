{ config, lib, ... }:
let
  cfg = config.youthlic.containers.miniflux;
in
{
  options = {
    youthlic.containers.miniflux = {
      enable = lib.mkEnableOption "miniflux container";
      adminCredentialsFile = lib.mkOption {
        type = lib.types.nonEmptyStr;
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
    containers."miniflux" = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.137.1";
      localAddress = "10.231.137.102";
      bindMounts = {
        "/var/lib/miniflux" = {
          hostPath = "/mnt/containers/miniflux/state";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "/mnt/containers/miniflux/database";
          isReadOnly = false;
        };
        "${cfg.adminCredentialsFile}" = {
          isReadOnly = true;
        };
      };
      forwardPorts = [
        {
          containerPort = 8485;
          hostPort = 8485;
          protocol = "tcp";
        }
        {
          containerPort = 8485;
          hostPort = 8485;
          protocol = "udp";
        }
      ];

      config =
        { lib, ... }:
        {
          imports = [
            ./../programs/miniflux.nix
            ./../programs/postgresql.nix
          ];

          systemd.tmpfiles.rules = [
            "d /var/lib/miniflux 770 miniflux miniflux -"
            "d /var/lib/postgresql 770 postgres postgres -"
            "d /run/secrets 770 root miniflux -"
          ];

          youthlic.programs = {
            miniflux = {
              enable = true;
              database = {
                user = "miniflux";
              };
              adminCredentialsFile = cfg.adminCredentialsFile;
            };
            postgresql = {
              enable = true;
              database = "miniflux";
              auth_method = "peer";
              version = "17";
            };
          };

          systemd.services.miniflux = {
            wants = [ "postgresql.service" ];
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
            wantedBy = [ "default.target" ];
          };

          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [ 8485 ];
              allowedUDPPorts = [ 8485 ];
            };
            useHostResolvConf = lib.mkForce false;
          };
          services.resolved.enable = true;
          system.stateVersion = "24.11";
        };
    };
  };
}
