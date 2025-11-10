{config, ...}: {
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
  };
}
