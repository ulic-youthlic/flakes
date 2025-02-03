{
  pkgs,
  ...
}:
{
  imports = [
    ./forgejo.nix
    ./networking.nix
    ./stylix.nix
    ./hardware-configuration.nix
    ./users
    ./disko-config.nix
  ];

  youthlic = {
    home-manager = {
      enable = true;
      unixName = "alice";
      hostName = "Cape";
    };
    users.deploy.enable = true;
    programs = {
      openssh.enable = true;
      tailscale.enable = true;
      conduwuit = {
        enable = true;
        serverName = "im.youthlic.fun";
      };
      mautrix-telegram.enable = true;
      caddy = {
        enable = true;
        baseDomain = "youthlic.fun";
      };
      juicity.server.enable = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Cape";

  time.timeZone = "America/New_York";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    wget
    git
    vim
    helix
    btop
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot.loader.grub = {
    enable = true;
  };

  system.stateVersion = "24.11";
}
