{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.containers.miniflux;
in {
  options = {
    youthlic.containers.miniflux = {
      enable = lib.mkEnableOption "miniflux container";
      adminCredentialsFile = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.containers.enable = true;
    containers."miniflux" = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostBridge = "${config.youthlic.containers.bridgeName}";
      localAddress = "192.168.111.102/24";
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

      config = {lib, ...}: {
        imports = [
          ./../programs/miniflux.nix
          ./../programs/postgresql.nix
        ];

        nixpkgs.pkgs = pkgs;

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
          wants = ["postgresql.service"];
          requires = ["postgresql.service"];
          after = ["postgresql.service"];
          wantedBy = ["default.target"];
        };

        networking = {
          defaultGateway = "192.168.111.1";
          firewall = {
            enable = true;
            allowedTCPPorts = [8485];
            allowedUDPPorts = [8485];
          };
          useHostResolvConf = lib.mkForce false;
        };
        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
