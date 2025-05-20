{
  pkgs,
  config,
  lib,
  rootPath,
  ...
}: let
  cfg = config.youthlic.programs.transmission;
in {
  options = {
    youthlic.programs.transmission = {
      enable = lib.mkEnableOption "transmission";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.groups."${config.services.transmission.group}".members = [
        config.youthlic.home-manager.unixName
      ];
      sops.secrets."transmission-config" = {
        sopsFile = rootPath + "/secrets/transmission.yaml";
      };
      services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        settings = {
          utp-enabled = true;
          watch-dir-enabled = true;
          default-trackers = builtins.readFile "${pkgs.TrackersListCollection}/all.txt";
          rpc-bind-address = "0.0.0.0";
          speed-limit-up-enabled = true;
          speed-limit-up = 1000;
        };
        openRPCPort = true;
        openPeerPorts = true;
        credentialsFile = "${config.sops.secrets.transmission-config.path}";
      };
    })
    (
      let
        caddy-cfg = config.youthlic.programs.caddy;
      in
        lib.mkIf (cfg.enable && caddy-cfg.enable) {
          services.transmission = {
            openRPCPort = lib.mkForce false;
            settings = {
              rpc-bind-address = lib.mkForce "127.0.0.1";
            };
          };
          services.caddy.virtualHosts = {
            "transmission.${caddy-cfg.baseDomain}" = {
              extraConfig = ''
                reverse_proxy 127.0.0.1:9091
              '';
            };
          };
        }
    )
  ];
}
