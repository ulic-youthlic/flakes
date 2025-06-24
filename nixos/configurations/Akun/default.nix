{
  inputs,
  pkgs,
  ...
}: {
  imports =
    (with inputs.nixos-hardware.nixosModules; [
      common-cpu-intel
      common-pc-laptop
      common-pc-laptop-ssd
    ])
    ++ [
      ./gui.nix
      ./hardware-configuration.nix
      ./stylix.nix
      ./users
      ./networking.nix
      ./disk-config.nix
    ];

  youthlic = {
    users.deploy.enable = true;
    home-manager = {
      enable = true;
      unixName = "david";
      hostName = "Akun";
    };
    i18n.enable = true;
    programs = {
      dae.enable = true;
      openssh.enable = true;
      kanata.enable = true;
      tailscale.enable = true;
      wshowkeys.enable = true;
    };
  };
  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Akun";

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
    spotify
    localsend
    zulip
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";
  services.scx.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["i915.enable_guc=2"];
  };
  nix = {settings = {system-features = ["gccarch-skylake"];};};
  hardware = {
    graphics.package = pkgs.mesa_git;
    intelgpu = {
      vaapiDriver = "intel-vaapi-driver";
      enableHybridCodec = true;
    };
  };

  system.stateVersion = "24.11";
}
