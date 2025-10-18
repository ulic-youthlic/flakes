{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.david.programs.nvchad;
in
{
  options = {
    david.programs.nvchad = {
      enable = lib.mkEnableOption "nvchad";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.nvchad = {
      enable = true;
      extraPackages = with pkgs; [
        editor-runtime
      ];
      neovim = pkgs.neovim-nightly;
      backup = true;
    };
  };
}
