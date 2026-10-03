{
  den.aspects.alice = {
    nixos =
      { lib, pkgs, ... }:
      {
        users.users.alice = {
          initialHashedPassword = "$y$j9T$eS5zCi4W.4IPpf3P8Tb/o1$xhumXY1.PJKmTguNi/zlljLbLemNGiubWoUEc878S36";
          isNormalUser = true;
          description = "alice";
          extraGroups = [
            "networkmanager"
            "libvirtd"
            "wheel"
            "video"
          ];
          shell = pkgs.fish;
        };
        programs.fish.enable = lib.mkDefault true;
      };
    homeManager.imports = [ ../_legacy/home/alice/modules ];
  };
}
