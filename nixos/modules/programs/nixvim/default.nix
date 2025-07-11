{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.nixvim;
in {
  imports = lib.youthlic.loadImports ./.;
  options = {
    youthlic.programs.nixvim = {
      enable = lib.mkEnableOption "nixvim";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      enableMan = true;
      colorschemes.gruvbox-material = {
        enable = true;
        autoLoad = true;
      };
      plugins.lualine.enable = true;
    };
  };
}
