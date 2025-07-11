{
  lib,
  inputs,
  ...
}: {
  imports =
    (with inputs; [
      niri-flake.homeModules.niri
      stylix.homeManagerModules.stylix
      chaotic.homeManagerModules.default
    ])
    ++ (lib.youthlic.loadImports ./.);
}
