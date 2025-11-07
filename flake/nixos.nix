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
      [
        "Tytonidae"
        "Cape"
        "Akun"
      ]
      |> (with lib; flip genAttrs makeNixosConfiguration);
  };
}
