{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      noctalia.homeModules.default
      zen-browser.homeModules.twilight
      spicetify-nix.homeManagerModules.spicetify
    ])
    ++ lib.youthlic.loadImports ./.;
}
