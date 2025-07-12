{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.david.programs.wluma;
in
{
  options = {
    david.programs.wluma = {
      enable = lib.mkEnableOption "wluma";
      extraSettings = lib.mkOption {
        inherit (options.services.wluma.settings) type;
        example = ''
          output = {
            backlight = [
              {
                name = "eDP-1";
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
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.wluma = {
      enable = true;
      settings = {
        als = {
          webcam = {
            video = 0;
            thresholds = {
              "0" = "night";
              "15" = "dark";
              "30" = "dim";
              "45" = "normal";
              "60" = "bright";
              "75" = "outdoors";
            };
          };
        };
      }
      // cfg.extraSettings;
      systemd = {
        enable = true;
      };
    };
  };
}
