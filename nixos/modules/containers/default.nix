{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.containers;
in {
  imports = [
    ./forgejo.nix
    ./miniflux.nix
  ];
  options = {
    youthlic.containers = {
      enable = lib.mkEnableOption "containers";
      interface = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };
      bridgeName = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "br0";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking = {
      bridges."${cfg.bridgeName}".interfaces = [
      ];
      interfaces."${cfg.bridgeName}" = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address = "192.168.111.1";
            prefixLength = 24;
          }
        ];
      };
      nat = {
        enable = true;
        internalInterfaces = [
          cfg.bridgeName
          "ve-+"
          "vb-+"
        ];
        externalInterface = cfg.interface;
      };
    };
  };
}
