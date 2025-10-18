{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
      betterfox-nix.homeModules.betterfox
      nix4nvchad.homeManagerModule
    ])
    ++ lib.youthlic.loadImports ./.;

  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
