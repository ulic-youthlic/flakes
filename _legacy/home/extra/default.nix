{
  lib,
  inputs,
  ...
}:
{
  imports =
    (lib.singleton inputs.catppuccin.homeModules.catppuccin) ++ (lib.youthlic.loadImports ./.);
}
