{ ... }:
{
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
      "20-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "balance-rr";
          MIIMonitorSec = "1s";
          PrimaryReselectPolicy = "better";
        };
      };
    };
    networks = {
      "20-eno2" = {
        networkConfig = {
          Bond = "bond0";
          PrimarySlave = true;
        };
        matchConfig = {
          Name = "eno2";
        };
      };
      "20-wlan0" = {
        networkConfig = {
          Bond = "bond0";
        };
        matchConfig = {
          Name = "wlan0";
        };
      };
      "20-bond0" = {
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        matchConfig = {
          Name = "bond0";
        };
      };
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
          EnableNetworkConfiguration = false;
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
