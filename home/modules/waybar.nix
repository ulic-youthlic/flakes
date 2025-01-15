{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.waybar;
in
{
  options = {
    youthlic.programs.waybar = {
      enable = lib.mkEnableOption "waybar";
      configDir = lib.mkOption {
        type = lib.types.path;
        example = ./config;
        description = ''
          path to waybar config dir
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
    ];
    xdg.configFile."waybar" = {
      enable = true;
      source = cfg.configDir;
      recursive = true;
    };
  };
}
