{inputs, ...}: let
  inherit (inputs.niri-flake.lib.kdl) node leaf flag;
in {
  david.programs.niri = {
    wluma.extraSettings = {
      output = {
        backlight = [
          {
            name = "eDP-1";
            path = "/sys/class/backlight/nvidia_0";
            capturer = "wayland";
          }
          {
            name = "DP-3";
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
    extraConfig = let
      output = node "output";
    in [
      (output ["DP-3"] [
        (leaf "mode" ["2560x1440@169.900"])
        (leaf "scale" [1.0])
        (leaf "position" [
          {
            x = 0;
            y = 0;
          }
        ])
        (leaf "transform" ["normal"])
        (flag "focus-at-startup")
      ])
      (output ["DP-1"] [
        (leaf "mode" ["2560x1440@169.900"])
        (leaf "scale" [1.0])
        (leaf "position" [
          {
            x = 0;
            y = 0;
          }
        ])
        (leaf "transform" ["normal"])
        (flag "focus-at-startup")
      ])
      (output ["eDP-1"] [
        (leaf "mode" ["2560x1440@165.003"])
        (leaf "scale" [1.5])
        (leaf "position" [
          {
            x = 2560;
            y = 0;
          }
        ])
        (leaf "transform" ["normal"])
      ])
    ];
  };
}
