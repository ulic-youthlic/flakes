{...}: let
  extraConfig = ''
    output "eDP-1" {
      mode "1920x1200@60.018"
      scale 1.0
      focus-at-startup
      position x=0 y=0
      transform "normal"
    }
    window-rule {
      match app-id="apps.regreet"
      open-on-output "eDP-1"
    }
  '';
in {
  youthlic.gui = {
    enabled = "niri";
    niri.extraConfig = extraConfig;
  };
}
