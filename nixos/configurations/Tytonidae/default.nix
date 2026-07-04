{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}: {
  imports =
    (with inputs.nixos-hardware.nixosModules; [
      common-hidpi
      common-cpu-intel
      # common-gpu-nvidia
      common-pc-laptop
      common-pc-laptop-ssd
      asus-battery
    ])
    ++ (with outputs; [
      nixosModules.gui
    ])
    ++ [inputs.lanzaboote.nixosModules.lanzaboote]
    ++ (lib.youthlic.loadImports ./.);

  youthlic = {
    lix.enable = true;
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
      # virtualbox = {
      #   enable = true;
      #   unixName = "david";
      # };
    };
    programs = {
      miniserve = {
        enable = true;
        apps = let
          cinny-template = config.youthlic.programs.miniserve.templates.cinny;
        in {
          cinny-1 = cinny-template {
            port = 9093;
          };
          cinny-2 = cinny-template {
            port = 9094;
          };
          cinny-3 = cinny-template {
            port = 9095;
          };
        };
      };
      bash.enable = true;
      guix.enable = true;
      # dae.enable = true;
      clash-verge.enable = true;
      openssh.enable = true;
      steam.enable = true;
      tailscale.enable = true;
      transmission.enable = true;
      nix-ld.enable = true;
      juicity.client.enable = true;
      wshowkeys.enable = true;
      obs.enable = true;
      garage.enable = true;
      # emacs.enable = true;
      sunshine.enable = true;
      kdeconnect.enable = true;
      rqbit = {
        enable = true;
        unixName = "david";
        ratelimitUpload = 10;
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
    radicle-desktop
    nix-output-monitor
    wget
    git
    vim
    helix

    vlc
    btop
    wechat-uos
    nvtopPackages.full
    localsend
    jq
    onefetch
    vesktop
    zulip
    aria2
    bitwarden-desktop

    juicity
    waypipe
    iperf3
    neovide
    prismlauncher

    sbctl
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
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
