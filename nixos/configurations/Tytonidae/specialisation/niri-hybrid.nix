{
  inputs,
  lib,
  ...
}: let
  extraConfig = ''
    output "DP-1" {
      mode "2560x1440@169.900"
      scale 1.0
      position x=0 y=0
      transform "normal"
      focus-at-startup
    }
    output "eDP-1" {
      mode "2560x1440@165.003"
      scale 1.5
      position x=2560 y=0
      transform "normal"
    }
    window-rule {
      match app-id="apps.regreet"
      open-on-output "DP-1"
    }
  '';
in {
  config.specialisation.niri-hybrid = {
    inheritParentConfig = true;
    configuration = {
      imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia];
      youthlic.gui.niri.extraConfig = lib.mkForce extraConfig;
      hardware.nvidia.prime.reverseSync.enable = lib.mkForce false;
    };
  };
}
