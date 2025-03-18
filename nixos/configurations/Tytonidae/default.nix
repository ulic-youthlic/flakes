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
      ./disk-config.nix
    ];

  youthlic = {
    home-manager = {
      enable = true;
      unixName = "david";
      hostName = "Tytonidae";
    };
    i18n.enable = true;
    programs = {
      guix.enable = true;
      dae.enable = true;
      openssh.enable = true;
      steam.enable = true;
      tailscale.enable = true;
      kanata.enable = true;
      kvm = {
        enable = true;
        unixName = "david";
      };
      transmission.enable = true;
      nix-ld.enable = true;
      juicity.client.enable = true;
    };
    gui.enabled = "niri";
  };

  specialisation = {
    cosmic = {
      inheritParentConfig = true;
      configuration = {
        youthlic.gui.enabled = lib.mkForce "cosmic";
      };
    };
    kde = {
      inheritParentConfig = true;
      configuration = {
        youthlic.gui.enabled = lib.mkForce "kde";
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
    vlc
    btop
    handbrake
    wechat-uos
    nvtopPackages.full
    spotify
    localsend
    jq
    onefetch
    vesktop
    gg
    aria2
    fractal

    juicity
    waypipe
    wineWow64Packages.waylandFull
    iperf3
    nvfetcher
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "24.11"; # Did you read the comment?
}
