{ ... }:
{
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "eno2" = {
        matchConfig.Name = "eno2";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
      };
    };
  };

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
    useDHCP = false;
    nftables = {
      enable = true;
    };

    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
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
