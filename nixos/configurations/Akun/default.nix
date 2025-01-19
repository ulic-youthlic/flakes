{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix
    ./users
    ./networking.nix
    ./disk-config.nix
  ];

  youthlic = {
    home-manager = {
      enable = true;
      unixName = "david";
      hostName = "Akun";
    };
    i18n.enable = true;
    programs = {
      # dae.enable = true;
      openssh.enable = true;
      kanata.enable = true;
    };
    gui.enabled = "kde";
  };
  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Akun";

  time.timeZone = "Asia/Shanghai";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    wget
    git
    vim
    helix

    element-desktop
    discord-ptb
    vlc
    btop
    spotify
    localsend
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # loader.grub = {
    #   efiSupport = true;
    #   efiInstallAsRemovable = true;
    # };
  };

  system.stateVersion = "24.11";
}
