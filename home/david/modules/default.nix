{ pkgs, ... }:
{
  imports = [
    ./wallpaper.nix
    ./programs
    ./xdg-dirs.nix
  ];
  config = {
    home.packages = with pkgs; [
      spacer
    ];
  };
}
