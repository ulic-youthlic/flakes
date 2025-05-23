{pkgs, ...}: let
  extraConfig = ''
    output "DP-3" {
      mode "2560x1440@169.900"
      scale 1.0
      position x=0 y=0
      transform "normal"
      focus-at-startup
    }
    output "eDP-1" {
      mode "2560x1440@165.003"
      scale 1.5
      position x=2560 y=0
      transform "normal"
    }
    window-rule {
      match app-id="apps.regreet"
      open-on-output "DP-3"
    }
  '';
in {
  youthlic.gui = {
    enabled = "niri";
    niri.extraConfig = extraConfig;
  };
}
