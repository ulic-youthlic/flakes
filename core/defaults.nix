{ den, ... }:
{
  # Included by every host and user.
  den.default.includes = [
    den.batteries.hostname
    den.aspects.catppuccin
    den.aspects.disko
    den.aspects.documentation
    den.aspects.nix
    den.aspects.nixpkgs
    den.aspects.sops
    den.aspects.sudo-rs
    den.aspects.system
    den.aspects.nh
  ];
}
