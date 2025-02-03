{ pkgs, ... }:
{
  imports = [
    ./wallpaper.nix
    ./programs
  ];
  config = {
    home.packages = with pkgs; [
      spacer
      devenv
    ];
  };
}
