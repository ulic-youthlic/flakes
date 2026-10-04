{
  inputs,
  pkgs,
  lib,
  outputs,
  ...
}:
{
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

  time.timeZone = "Asia/Shanghai";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    radicle-desktop
    nix-output-monitor
    wget
    git
    vim-full
    steelix

    btop
    localsend
    zulip
    wechat
  ];

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    package = pkgs.scx.rustscheds;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "i915.enable_guc=2" ];
  };
  nix = {
    settings = {
      system-features = [ "gccarch-skylake" ];
    };
  };
  hardware = {
    graphics.package = pkgs.mesa;
    intelgpu = {
      vaapiDriver = "intel-vaapi-driver";
      enableHybridCodec = true;
    };
  };

}
