{
  den.aspects.alacritty.homeManager =
    { lib, pkgs, ... }:
    {
      catppuccin.alacritty.enable = false;
      programs.alacritty = {
        enable = true;
        settings =
          (
            with lib;
            pipe ./alacritty.toml [
              builtins.readFile
              fromTOML
            ]
          )
          // {
            general.import = [
              "${pkgs.alacritty-theme}/share/alacritty-theme/catppuccin_mocha.toml"
            ];
          };
      };
    };
}
