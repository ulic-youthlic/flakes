{
  inputs,
  lib,
  config,
  self,
  ...
}:
let
  inherit (self) outputs;
  rootPath = ../.;
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
          inputs.nixpkgs-patcher.lib.nixosSystem {
            nixpkgsPatcher.inputs = inputs;
            modules = [ (rootPath + "/_legacy/nixos/configurations/${hostName}") ];
            specialArgs = {
              inherit
                inputs
                outputs
                rootPath
                ;
              inherit (config.flake) lib;
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
