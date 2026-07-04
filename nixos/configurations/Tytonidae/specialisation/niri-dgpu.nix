{ inputs, ... }: {
  # config.specialisation.niri-dgpu = {
  #   inheritParentConfig = true;
  #   configuration = {
  #     disabledModules = [
  #       inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  #     ];
  #     imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime];
  #     hardware.nvidia.prime = {
  #       reverseSync.enable = true;
  #       offload.enable = false;
  #     };
  #   };
  # };
}
