{
  # Let the video group change backlight and LED brightness.
  den.aspects.backlight.nixos =
    { lib, pkgs, ... }:
    {
      services.udev = {
        enable = true;
        extraRules = ''
          ACTION=="add", SUBSYSTEM=="backlight", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video /sys/class/backlight/%k/brightness"
          ACTION=="add", SUBSYSTEM=="backlight", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys/class/backlight/%k/brightness"
          ACTION=="add", SUBSYSTEM=="leds", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video /sys/class/leds/%k/brightness"
          ACTION=="add", SUBSYSTEM=="leds", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys/class/leds/%k/brightness"
        '';
      };
    };
}
