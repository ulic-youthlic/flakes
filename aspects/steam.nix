{
  den.aspects.steam.xdg-mime = {
    "x-scheme-handler/steam" = [ "steam.desktop" ];
    "x-scheme-handler/steamlink" = [ "steam.desktop" ];
  };

  den.aspects.steam.nixos =
    { pkgs, ... }:
    {
      hardware.graphics.enable32Bit = true;
      environment.systemPackages = with pkgs; [
        gamescope
      ];
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };
    };
}
