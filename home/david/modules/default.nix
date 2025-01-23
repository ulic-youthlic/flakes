{ pkgs, ... }:
{
  imports = [
    ./wallpaper
  ];
  config = {
    home.packages = with pkgs; [
      spacer
    ];
  };
}
