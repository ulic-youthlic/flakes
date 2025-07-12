{ ... }:
{
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "10-eno2" = {
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        matchConfig = {
          Path = "pci-0000:00:1f.6";
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
