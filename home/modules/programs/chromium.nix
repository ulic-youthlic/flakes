{ lib, config, ... }:
let
  cfg = config.youthlic.programs.chromium;
in
{
  options = {
    youthlic.programs.chromium = {
      enable = lib.mkEnableOption "chromium";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-wayland-ime=true"
        "--enable-features=UseOzonePlatform"
      ];
    };
  };
}
