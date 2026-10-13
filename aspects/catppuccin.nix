{ inputs, ... }:
{
  den.aspects.catppuccin = {
    nixos = {
      # Keyed so a second import into the same system is deduplicated.
      imports = [
        {
          key = "inputs:catppuccin/nixosModules.catppuccin";
          imports = [ inputs.catppuccin.nixosModules.catppuccin ];
        }
      ];
      catppuccin = {
        enable = true;
        flavor = "latte";
        tty.flavor = "mocha";
        fish.flavor = "mocha";
      };
    };
    homeManager = {
      # Keyed so a second import into the same home is deduplicated.
      imports = [
        {
          key = "inputs:catppuccin/homeModules.catppuccin";
          imports = [ inputs.catppuccin.homeModules.catppuccin ];
        }
      ];
      catppuccin = {
        enable = true;
        flavor = "latte";
        qt5ct.enable = true;

        # Would otherwise default on with catppuccin.enable and inject
        # Papirus-Light into GTK apps, which conflicts with the plain Adwaita
        # icons set by ./theme-gtk via gtk.enable.
        gtk.icon.enable = false;
      };
    };
  };
}
