{ inputs, ... }:
{
  den.aspects.base.catppuccin.nixos = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];
    catppuccin = {
      enable = true;
      flavor = "latte";
      tty.flavor = "mocha";
      fish.flavor = "mocha";
    };
  };
}
