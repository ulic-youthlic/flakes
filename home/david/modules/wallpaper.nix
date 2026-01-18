{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.david.wallpaper;
in {
  options = {
    david.wallpaper = {
      enable = lib.mkEnableOption "wallpaper";
      path = lib.mkOption {
        type = lib.types.str;
        default = "pic/wallpapaers";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.file."${config.david.wallpaper.path}" = {
      force = true;
      recursive = true;
      source = toString pkgs.wallpapers;
    };
  };
}
