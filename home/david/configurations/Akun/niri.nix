{
  config,
  inputs,
  ...
}: let
  inherit (inputs.niri-flake.lib.kdl) node leaf flag;
in {
  david.programs.niri = {
    waybar.settings = let
      cfg = config.david.programs.niri.waybar;
    in [(cfg.template // (cfg.helper.mkBacklight "intel_backlight") // {output = "eDP-1";})];
    wluma.extraSettings = {
      output = {
        backlight = [
          {
            name = "eDP-1";
            path = "/sys/class/backlight/intel_backlight";
            capturer = "wayland";
          }
        ];
      };
    };
    extraConfig = let
      output = node "output";
    in [
      (output ["eDP-1"] [
        (leaf "mode" ["1920x1200@60.018"])
        (leaf "scale" [1.0])
        (flag "focus-at-startup")
        (leaf "position" [
          {
            x = 0;
            y = 0;
          }
        ])
        (leaf "transform" ["normal"])
      ])
    ];
  };
}
