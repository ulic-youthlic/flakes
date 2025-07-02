{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.youthlic.virtualisation.waydroid;
in {
  options = {
    youthlic.virtualisation.waydroid = {
      enable = lib.mkEnableOption "waydroid";
    };
  };
  config = {
    virtualisation.waydroid = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [waydroid-script];
  };
}
