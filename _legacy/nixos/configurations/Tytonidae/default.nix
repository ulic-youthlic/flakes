{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  imports =
    (with inputs.nixos-hardware.nixosModules; [
      common-hidpi
      common-cpu-intel
      common-gpu-nvidia
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
      upower.enable = true;
      miniserve = {
        enable = true;
        apps =
          let
            cinny-template = config.youthlic.programs.miniserve.templates.cinny;
            ariang-template = config.youthlic.programs.miniserve.templates.ariang;
          in
          {
            cinny-1 = cinny-template {
              port = 9093;
            };
            cinny-2 = cinny-template {
              port = 9094;
            };
            cinny-3 = cinny-template {
              port = 9095;
            };
            ariang = ariang-template {
              port = 9096;
            };
          };
      };
      readest = {
        enable = true;
        port = 9097;
        environment.SITE_URL = "http://127.0.0.1:9097";
      };
      webdav-proxy = {
        enable = true;
        upstream = "https://toi.teracloud.jp";
        allowedOrigins = [ "http://127.0.0.1:9097" ];
      };
      bash.enable = true;
      guix.enable = true;
      openssh.enable = true;
      steam.enable = true;
      tailscale.enable = true;
      nix-ld.enable = true;
      juicity.client.enable = true;
      wshowkeys.enable = true;
      obs.enable = true;
      garage.enable = true;
      # emacs.enable = true;
      kdeconnect.enable = true;
      rqbit = {
        enable = true;
        unixName = "david";
        ratelimitUpload = 10;
      };
      sing-box.enable = true;
    };
  };

  time.timeZone = "Asia/Shanghai";

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  environment.systemPackages = with pkgs; [
    comma
    radicle-desktop
    nix-output-monitor
    wget
    git
    vim-full
    steelix

    btop
    wechat
    nvtopPackages.full
    localsend
    jq
    onefetch
    zulip
    aria2
    bitwarden-desktop

    juicity
    waypipe
    iperf3
    prismlauncher

    sbctl
  ];

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
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

}
