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
    ];
  };
  services.udev = {
    enable = true;
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video /sys/class/leds/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys/class/leds/%k/brightness"
    '';
  };
  programs.fish.enable = true;
  users.users.david.shell = pkgs.fish;
  users.users.david.openssh.authorizedKeys.keyFiles = [
    ./tytonidae.pub
  ];
}
