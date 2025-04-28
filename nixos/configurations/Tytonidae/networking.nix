{...}: {
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "10-eno2" = {
        dns = [
          "192.168.31.1"
        ];
        address = [
          "192.168.31.25/24"
        ];
        # gateway = [
        #   "192.168.31.1"
        # ];
        routes = [
          {
            Gateway = "192.168.31.1";
          }
        ];
        matchConfig.Name = "eno2";
        linkConfig.RequiredForOnline = "routable";
        # networkConfig = {
        #   DHCP = "yes";
        #   IPv6AcceptRA = true;
        # };
      };
    };
  };

  networking = {
    networkmanager.enable = false;
    # useNetworkd = true;
    useDHCP = false;
    nftables = {
      enable = true;
    };

    wireless.iwd = {
      enable = true;
      settings = {
        IPv6 = {
          Enabled = true;
        };
        General = {
          EnableNetworkConfiguration = true;
        };
        Settings = {
          AutoConnect = true;
        };
        Network = {
          EnableIPv6 = true;
          NameResolvingService = "systemd";
        };
      };
    };
    firewall.enable = false;
  };
}
