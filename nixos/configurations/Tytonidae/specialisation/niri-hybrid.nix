{inputs, ...}: {
  config.specialisation.niri-hybrid = {
    inheritParentConfig = true;
    configuration = {
      disabledModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      ];
      imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia];
      hardware.nvidia.prime = {
        reverseSync.enable = false;
        offload.enable = true;
      };
      services.xserver.videoDrivers = ["nvidia"];
    };
  };
}
