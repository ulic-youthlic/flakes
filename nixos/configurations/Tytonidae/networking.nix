{...}: {
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    links = {
      "10-eno2" = {
        matchConfig = {
          Path = "pci-0000:00:1f.6";
        };
        linkConfig = {
          Name = "eno2";
        };
      };
      "10-wlan0" = {
        matchConfig = {
          Path = "pci-0000:00:14.3";
        };
        linkConfig = {
          Name = "wlan0";
        };
      };
    };
    netdevs = {
      #   "20-bond0" = {
      #     netdevConfig = {
      #       Kind = "bond";
      #       Name = "bond0";
      #     };
      #     bondConfig = {
      #       Mode = "balance-alb";
      #       MIIMonitorSec = "1s";
      #       PrimaryReselectPolicy = "better";
      #     };
      #   };
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
        };
      };
    };
    networks = {
      "20-br0" = {
        networkConfig = {
          # Bond = "bond0";
          # PrimarySlave = true;

          DHCP = "yes";
          IPv6AcceptRA = true;

          IPMasquerade = "yes";
          IPv4Forwarding = "yes";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        matchConfig = {
          Name = "br0";
        };
      };
      "20-eno2" = {
        matchConfig = {
          Name = "eno2";
        };
        networkConfig = {
          Bridge = "br0";
        };
      };
      # "20-wlan0" = {
      #   matchConfig = {
      #     Name = "wlan0";
      #   };

      #   address = ["192.168.110.1/24"];
      #   networkConfig = {
      #     DHCPServer = "yes";
      #     IPMasquerade = "yes";
      #     IPv4Forwarding = "yes";
      #   };
      #   dhcpServerConfig = {
      #     PoolOffset = 100;
      #     PoolSize = 20;
      #     EmitDNS = "yes";
      #     DNS = "8.8.8.8";
      #   };
      # };
      # "20-wlan0" = {
      #   networkConfig = {
      #     # Bond = "bond0";
      #   };
      #   matchConfig = {
      #     Name = "wlan0";
      #   };
      # };

      # "20-bond0" = {
      #   networkConfig = {
      #     DHCP = "yes";
      #     IPv6AcceptRA = true;
      #   };
      #   linkConfig = {
      #     RequiredForOnline = "routable";
      #   };
      #   matchConfig = {
      #     Name = "bond0";
      #   };
      # };
    };
  };

  networking = {
    networkmanager.enable = false;
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
          # EnableNetworkConfiguration = false;
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
