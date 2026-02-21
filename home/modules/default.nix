{
  lib,
  inputs,
  ...
}: {
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
      betterfox-nix.homeModules.betterfox
      nix4nvchad.homeManagerModule
      noctalia.homeModules.default
      zen-browser.homeModules.twilight
      spicetify-nix.homeManagerModules.spicetify
    ])
    ++ lib.youthlic.loadImports ./.;

  config = {
    youthlic.programs.direnv.enable = true;
  };
}
