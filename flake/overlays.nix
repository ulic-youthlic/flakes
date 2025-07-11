{
  self,
  inputs,
  lib,
  rootPath,
  ...
}: let
  inherit (self) outputs;
  importWithArgs = lib.flip import {inherit inputs outputs;};
in {
  flake.overlays =
    [
      "modifications"
      "additions"
    ]
    |> (with lib; flip genAttrs (name: importWithArgs (rootPath + "/overlays/${name}")));
}
