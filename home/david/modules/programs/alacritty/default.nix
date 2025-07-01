{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.david.programs.alacritty;
in {
  options = {
    david.programs.alacritty = {
      enable = lib.mkEnableOption "alacritty";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = pkgs.alacritty_git;
      settings =
        (./alacritty.toml |> builtins.readFile |> builtins.fromTOML)
        // {
          colors = lib.mkForce {};
          font.size = lib.mkForce 16;
          window.opacity = lib.mkForce 0.8;
          general.import = [
            "${pkgs.alacritty-theme}/share/alacritty-theme/gruvbox_dark.toml"
          ];
        };
    };
  };
}
