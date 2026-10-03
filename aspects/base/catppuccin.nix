{ inputs, ... }:
{
  den.aspects.base.catppuccin = {
    nixos = {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];
      catppuccin = {
        enable = true;
        flavor = "latte";
        tty.flavor = "mocha";
        fish.flavor = "mocha";
      };
    };
    homeManager = {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      catppuccin = {
        enable = true;
        flavor = "latte";
        qt5ct.enable = true;
      };
    };
  };
}
