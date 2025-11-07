{
  self,
  inputs,
  lib,
  rootPath,
  ...
}:
let
  inherit (self) outputs;
  importWithArgs = lib.flip import { inherit inputs outputs; };
in
{
  flake.overlays =
    with lib;
    pipe
      [
        "modifications"
        "additions"
      ]
      [ (flip genAttrs (name: importWithArgs (rootPath + "/overlays/${name}"))) ];
}
