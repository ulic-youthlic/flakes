{ pkgs, rootPath, ... }:
{
  stylix = {
    enable = true;
    image = rootPath + "/assets/wallpaper/01.png";
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    fonts = {
      serif = {
        package = pkgs.lxgw-wenkai;
        name = "LXGW WenKai";
      };
      sansSerif = {
        package = pkgs.noto-fonts-cjk-serif;
        name = "Noto Serif CJK SC";
      };
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
