{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.niri;
in
{
  options = {
    youthlic.programs.niri = {
      enable = lib.mkEnableOption "niri";
      config = lib.mkOption {
        type = lib.types.path;
        example = ./config.kdl;
        description = ''
          the pach to config.kdl
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
      swaybg
      xwayland-satellite
      niri-unstable
    ];
    youthlic.programs = {
      fuzzel.enable = true;
      wluma.enable = true;
      waybar.enable = true;
      swaync.enable = true;
    };
    programs.niri = {
      config = builtins.readFile cfg.config;
      package = pkgs.niri-unstable;
    };
  };
}
