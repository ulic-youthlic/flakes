{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
{
  imports =
    (with inputs.nixos-hardware.nixosModules; [
      common-hidpi
      common-cpu-intel
      common-gpu-nvidia-nonprime
      common-pc-laptop
      common-pc-laptop-ssd
      asus-battery
    ])
    ++ (with outputs; [
      nixosModules.gui
    ])
    ++ [ inputs.lanzaboote.nixosModules.lanzaboote ]
    ++ (lib.youthlic.loadImports ./.);

  youthlic = {
    home-manager = {
      enable = true;
      unixName = "david";
      hostName = "Tytonidae";
    };
    hardware.asus.enable = true;
    i18n.enable = true;
    virtualisation = {
      kvm = {
        enable = true;
        unixName = "david";
      };
      waydroid.enable = true;
    };
    programs = {
      bash.enable = true;
      guix.enable = true;
      dae.enable = true;
      openssh.enable = true;
      steam.enable = true;
      tailscale.enable = true;
      kanata.enable = true;
      transmission.enable = true;
      nix-ld.enable = true;
      juicity.client.enable = true;
      owncast.enable = true;
      wshowkeys.enable = true;
      obs.enable = true;
      garage.enable = true;
      # emacs.enable = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Tytonidae";

  time.timeZone = "Asia/Shanghai";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    radicle-node
    nix-output-monitor
    wget
    git
    vim
    helix

    fluffychat
    kdePackages.neochat
    vlc
    btop
    handbrake
    wechat
    nvtopPackages.full
    spotify
    localsend
    jq
    onefetch
    vesktop
    zulip
    aria2

    juicity
    waypipe
    wineWow64Packages.waylandFull
    iperf3
    nixvim
    neovide

    sbctl
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    package = pkgs.scx_git.rustscheds;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
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
