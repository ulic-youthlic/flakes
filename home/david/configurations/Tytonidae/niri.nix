{
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.niri;
in {
  david.programs.niri = lib.mkIf cfg.enable {
    wluma.extraSettings = {
      output = {
        backlight = [
          {
            name = "eDP-2";
            path = "/sys/class/backlight/nvidia_0";
            capturer = "wayland";
          }
          {
            name = "DP-1";
            path = "/sys/class/backlight/ddcci13";
            capturer = "wayland";
          }
        ];
      };
      keyboard = [
        {
          name = "keyboard-asus";
          path = "/sys/bus/platform/devices/asus-nb-wmi/leds/asus::kbd_backlight";
        }
      ];
    };
  };
}
