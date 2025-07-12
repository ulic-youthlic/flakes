{
  makeNixvimWithModule,
  pkgs,
  lib,
  nixvimPlugins,
  neovim_git,
}:
makeNixvimWithModule {
  inherit pkgs;
  extraSpecialArgs = {
    inherit nixvimPlugins;
  };
  module = {
    imports = with lib; youthlic.loadImports' ./. (filter (name: !hasSuffix "/package.nix" (toString name)));
    enableMan = true;
    plugins.lualine.enable = true;
    package = neovim_git;
    performance = {
      # combinePlugins = {
      #   enable = true;
      #   standalonePlugins = [];
      # };
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        luaLib = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
    wrapRc = true;
    luaLoader.enable = true;
  };
}
