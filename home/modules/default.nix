{
  lib,
  inputs,
  ...
}: {
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
      betterfox-nix.homeManagerModules.betterfox
    ])
    ++ lib.youthlic.loadImports ./.;

  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
