{
  inputs,
  lib,
  self,
  ...
}: let
  rootPath = ./..;
  inherit (self) outputs;
  inherit (inputs) nixpkgs;
  defaultNixosModule = import (rootPath + "/nixos/modules");
in {
  flake = {
    nixosModules.default = defaultNixosModule;
    nixosConfigurations = let
      makeNixConfiguration = hostName:
        nixpkgs.lib.nixosSystem {
          modules =
            [defaultNixosModule]
            ++ [
              (rootPath + "/nixos/configurations/${hostName}")
            ];
          specialArgs = {
            inherit inputs outputs rootPath;
          };
        };
    in
      [
        "Tytonidae"
        "Cape"
        "Akun"
      ]
      |> (
        with lib;
          flip genAttrs makeNixConfiguration
      );
  };
}
