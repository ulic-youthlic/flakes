{
  den.aspects.containers = {
    nixos =
      {
        host,
        ...
      }:
      let
        cfg = host.containers;
      in
      {
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
  };
}
