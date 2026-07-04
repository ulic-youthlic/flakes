{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      niri-flake.homeModules.niri
      stylix.homeManagerModules.stylix
    ])
    ++ (lib.youthlic.loadImports ./.);
}
