{
  inputs,
  lib,
  ...
}: {
  config.specialisation.niri-hybrid = {
    inheritParentConfig = true;
    configuration = {
      imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia];
      hardware.nvidia.prime.reverseSync.enable = lib.mkForce false;
    };
  };
}
