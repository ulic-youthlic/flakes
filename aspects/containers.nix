{
  den.aspects.containers = {
    nixos =
      {
        host,
        lib,
        ...
      }:
      let
        cfg = host.containers;
      in
      {
        # Each container runs one service, managed from the host: it needs no
        # documentation, no command-not-found and no Nix of its own.
        options.containers = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              config.config = {
                documentation.enable = false;
                programs.command-not-found.enable = false;
                nix.enable = false;
              };
            }
          );
        };

        config.networking = {
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
  };
}
