{ ... }:
{
  systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks = {
      "ens3" = {
        matchConfig.Name = "ens3";
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
    firewall.enable = true;
  };
}
