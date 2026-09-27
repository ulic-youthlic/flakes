{
  inputs,
  rootPath,
  lib,
  config,
  ...
}:
{
  imports =
    (lib.singleton inputs.den-overlays.flakeModules.default)
    ++ lib.youthlic.loadImports (rootPath + "/overlays");
  flake.overlays.default =
    let
      others = removeAttrs config.flake.overlays [ "default" ];
      names = lib.sort (a: b: a < b) (builtins.attrNames others);
    in
    lib.composeManyExtensions (map (n: others.${n}) names);
}
