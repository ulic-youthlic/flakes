{
  inputs,
  lib,
  self,
  rootPath,
  ...
}:
let
  inherit (self) outputs;
in
{
  flake = {
    nixosModules = {
      default = import (rootPath + "/_legacy/nixos/modules/top-level");
      gui = import (rootPath + "/_legacy/nixos/modules/top-level/gui.nix");
    };
    nixosConfigurations =
      let
        makeNixosConfiguration =
          hostName:
          lib.nixpkgs-patcher.nixosSystem {
            nixpkgsPatcher.inputs = inputs;
            modules = [ (rootPath + "/_legacy/nixos/configurations/${hostName}") ];
            specialArgs = {
              inherit
                inputs
                outputs
                rootPath
                lib
                ;
            };
          };
      in
      with lib;
      pipe
        [
          "Tytonidae"
          "Cape"
          "Akun"
        ]
        [ (flip genAttrs makeNixosConfiguration) ];
  };
}
