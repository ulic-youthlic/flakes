{
  makeNixvimWithModule,
  pkgs,
  lib,
}:
makeNixvimWithModule {
  inherit pkgs;
  module = {
    imports = with lib; youthlic.loadImports' ./. (filter (name: !hasSuffix "/package.nix" (toString name)));
    enableMan = true;
    plugins.lualine.enable = true;
  };
}
