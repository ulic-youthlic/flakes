{
  lib,
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
    ])
    ++ (lib.youthlic.loadImports ./.);
}
