{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.steam;
in {
  options = {
    youthlic.programs.steam = {
      enable = lib.mkEnableOption "steam";
    };
  };
  config = lib.mkIf cfg.enable {
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
