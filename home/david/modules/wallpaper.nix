{
  rootPath,
  lib,
  config,
  ...
}: let
  cfg = config.david.wallpaper;
in {
  options = {
    david.wallpaper = {
      enable = lib.mkEnableOption "wallpaper";
    };
  };
  config = lib.mkIf cfg.enable {
    home.file."wallpaper" = {
      force = true;
      recursive = true;
      source = rootPath + "/assets/wallpaper";
    };
  };
}
