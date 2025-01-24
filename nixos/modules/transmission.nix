{
  pkgs,
  config,
  lib,
  inputs,
  rootPath,
  ...
}:
let
  cfg = config.youthlic.programs.transmission;
in
{
  options = {
    youthlic.programs.transmission = {
      enable = lib.mkEnableOption "transmission";
    };
  };
  config = lib.mkIf cfg.enable {
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
        default-trackers = builtins.readFile "${inputs.bt-tracker}/all.txt";
      };
      openRPCPort = true;
      openPeerPorts = true;
      credentialsFile = "${config.sops.secrets.transmission-config.path}";
    };
  };
}
