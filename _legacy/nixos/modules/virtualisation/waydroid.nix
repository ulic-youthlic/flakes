{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.virtualisation.waydroid;
in
{
  options = {
    youthlic.virtualisation.waydroid = {
      enable = lib.mkEnableOption "waydroid";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.waydroid = {
      enable = true;
    };
    environment.systemPackages = [ pkgs.nur.repos.ataraxiasjel.waydroid-script ];
  };
}
