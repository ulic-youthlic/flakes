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
