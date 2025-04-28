{pkgs, ...}: {
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
  };

  users.mutableUsers = false;
  programs.fish.enable = true;
  users.users.alice.shell = pkgs.fish;
  users.users.alice.openssh.authorizedKeys.keyFiles = [
    ./cape.pub
  ];
}
