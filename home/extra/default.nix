{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      stylix.homeManagerModules.stylix
    ])
    ++ (lib.youthlic.loadImports ./.);
}
