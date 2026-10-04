{ den, ... }:
{
  # Included by every host and user.
  den.default.includes = [
    den.batteries.hostname
    den.aspects.base.args
    den.aspects.base.catppuccin
    den.aspects.base.disko
    den.aspects.base.documentation
    den.aspects.base.nix
    den.aspects.base.nixpkgs
    den.aspects.base.sops
    den.aspects.base.sudo-rs
    den.aspects.base.system
    den.aspects.tty.nh
  ];
}
