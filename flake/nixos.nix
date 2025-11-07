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
      default = import (rootPath + "/nixos/modules/top-level");
      gui = import (rootPath + "/nixos/modules/top-level/gui.nix");
    };
    nixosConfigurations =
      let
        makeNixosConfiguration =
          hostName:
          lib.nixosSystem {
            modules = [ (rootPath + "/nixos/configurations/${hostName}") ];
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
