{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      nixos-hardware.nixosModules.asus-fx506hm
    ])
    ++ [
      ./users
      ./stylix.nix

      # Include the hardware related config
      ./hardware-configuration.nix
      ./networking.nix
    ];

  youthlic = {
    home-manager = {
      enable = true;
      unixName = "david";
      hostName = "Tytonidae";
    };
    i18n.enable = true;
    programs = {
      dae.enable = true;
      openssh.enable = true;
      steam.enable = true;
      tailscale.enable = true;
      kanata.enable = true;
    };
    gui.enabled = "cosmic";
  };

  specialisation = {
    niri = {
      inheritParentConfig = true;
      configuration = {
        youthlic.gui.enabled = lib.mkForce "niri";
      };
    };
  };

  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Tytonidae";

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
    handbrake
    wechat-uos
    nvtopPackages.full
    spotify
    localsend
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "24.11"; # Did you read the comment?
}
