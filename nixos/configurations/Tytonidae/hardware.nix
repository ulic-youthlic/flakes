{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.cudaSupport = true;
  services = {
    hardware.bolt.enable = true;
    fstrim.enable = true;
  };
  nix = {settings = {system-features = ["gccarch-alderlake"];};};
  hardware = {
    graphics.package = pkgs.mesa_git;
    intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      prime = {
        reverseSync.enable = lib.mkDefault true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  boot.binfmt = {
    emulatedSystems = [
      "aarch64-linux"
      "x86_64-windows"
      "wasm64-wasi"
    ];
  };
}
