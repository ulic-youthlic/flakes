{ lib, config, ... }:
let
  cfg = config.youthlic.xdg-dirs;
in
{
  options = {
    youthlic.xdg-dirs = {
      enable = lib.mkEnableOption "xdg-dirs";
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.userDirs = {
      enable = true;
      download = "${config.home.homeDirectory}/dls";
      documents = "${config.home.homeDirectory}/doc";
      music = "${config.home.homeDirectory}/mus";
      pictures = "${config.home.homeDirectory}/pic";
      videos = "${config.home.homeDirectory}/vid";
      templates = "${config.home.homeDirectory}/tpl";
      publicShare = "${config.home.homeDirectory}/pub";
      desktop = "${config.home.homeDirectory}/dsk";
      createDirectories = true;
    };
  };
}
