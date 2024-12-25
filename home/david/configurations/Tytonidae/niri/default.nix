{ pkgs, ... }:
{
  programs.niri = {
    config = builtins.readFile ./config.kdl;
  };
  home.packages = with pkgs; [
    mako
    swaybg
    xwayland-satellite
    waybar
  ];
}
