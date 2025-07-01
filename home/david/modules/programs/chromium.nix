{
  lib,
  config,
  ...
}: let
  cfg = config.david.programs.chromium;
in {
  options = {
    david.programs.chromium = {
      enable = lib.mkEnableOption "chromium";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=wayland"
        "--process-per-site"
        "--enable-wayland-ime"
        "--wayland-text-input-version=3"
        "--enable-features=UseOzonePlatform"
      ];
    };
  };
}
