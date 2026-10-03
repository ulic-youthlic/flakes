{ lib, ... }:
let
  inherit (lib.nix-kdl.dsl) n;
in
{
  david.programs.niri.config = [
    (n "debug" [
      (n "render-drm-device" "/dev/dri/by-path/pci-0000:00:02.0-render") # Intel
      (n "ignore-drm-device" "/dev/dri/by-path/pci-0000:01:00.0-render") # NVIDIA
    ])
  ];
}
