{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.gui;
in
{
  config = lib.mkIf (cfg.enabled == "niri") {
    environment.systemPackages = with pkgs; [
      bluez
    ];
    hardware.bluetooth = {
      enable = true;
    };
    services.xserver = {
      enable = true;
      xkb = {
        layout = "cn";
        variant = "";
      };
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
