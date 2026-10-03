{ den, ... }:
{
  den.aspects.david = {
    includes = with den.aspects; [
      dev.git
      dev.gpg
      dev.helix
      dev.jujutsu
      home.xdg-dirs
      shell.atuin
      shell.bash
      shell.direnv
      shell.eza
      shell.fish
      shell.fzf
      shell.starship
      shell.yazi
      shell.zoxide
    ];
    nixos =
      { lib, pkgs, ... }:
      {
        users.users.david = {
          initialHashedPassword = "$y$j9T$eS5zCi4W.4IPpf3P8Tb/o1$xhumXY1.PJKmTguNi/zlljLbLemNGiubWoUEc878S36";
          isNormalUser = true;
          description = "david";
          extraGroups = [
            "networkmanager"
            "libvirtd"
            "wheel"
            "video"
            "input"
          ];
          shell = pkgs.fish;
        };
        programs.fish.enable = lib.mkDefault true;
      };
    homeManager.imports = [ ../_legacy/home/david/modules ];
  };
}
