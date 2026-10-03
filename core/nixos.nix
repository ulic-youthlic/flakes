{
  flake.nixosModules = {
    default = import ../_legacy/nixos/modules/top-level;
    gui = import ../_legacy/nixos/modules/top-level/gui.nix;
  };
}
