{pkgs, ...}: {
  nixpkgs.config.cudaSupport = true;
  services = {
    hardware.bolt.enable = true;
    fstrim.enable = true;
  };
  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        vaapiIntel
        libva
        libvdpau-va-gl
        vaapiVdpau
        ocl-icd
        intel-ocl
        intel-compute-runtime
        nvidia-vaapi-driver
        intel-media-driver
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };
}
