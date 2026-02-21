{
  inputs,
  pkgs,
  lib,
  outputs,
  ...
}: {
  imports =
    (with inputs.nixos-hardware.nixosModules; [
      common-cpu-intel
      common-pc-laptop
      common-pc-laptop-ssd
    ])
    ++ [
      outputs.nixosModules.gui
    ]
    ++ (lib.youthlic.loadImports ./.);

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
      obs.enable = true;
    };
  };
  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Akun";

  time.timeZone = "Asia/Shanghai";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    radicle-desktop
    nix-output-monitor
    wget
    git
    vim
    helix

    fluffychat
    kdePackages.neochat
    vlc
    btop
    localsend
    zulip
    wechat
    neovide
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    package = pkgs.scx.rustscheds;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["i915.enable_guc=2"];
  };
  nix = {
    settings = {
      system-features = ["gccarch-skylake"];
    };
  };
  hardware = {
    graphics.package = pkgs.mesa;
    intelgpu = {
      vaapiDriver = "intel-vaapi-driver";
      enableHybridCodec = true;
    };
  };

  system.stateVersion = "24.11";
}
