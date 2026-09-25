{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
      noctalia.homeModules.default
      zen-browser.homeModules.twilight
      spicetify-nix.homeManagerModules.spicetify
      catppuccin.homeModules.catppuccin
    ])
    ++ lib.youthlic.loadImports ./.;

  config = {
    youthlic.programs.direnv.enable = true;
  };
}
