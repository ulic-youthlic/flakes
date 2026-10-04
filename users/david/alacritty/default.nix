{
  den.aspects.david.alacritty.homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        programs.alacritty = {
          enable = true;
          settings =
            (
              with lib;
              pipe ./alacritty.toml [
                builtins.readFile
                builtins.fromTOML
              ]
            )
            // {
              colors = lib.mkForce { };
              font.size = lib.mkForce 16;
              window.opacity = lib.mkForce 0.8;
              general.import = [
                "${pkgs.alacritty-theme}/share/alacritty-theme/gruvbox_dark.toml"
              ];
            };
        };
      };
    };
}
