{
  inputs,
  lib,
  self,
  ...
}: let
  rootPath = ./..;
  inherit (self) outputs;
  inherit (inputs) nixpkgs;
in {
  flake = {
    nixosModules = {
      default = import (rootPath + "/nixos/modules/top-level");
      gui = import (rootPath + "/nixos/modules/top-level/gui.nix");
    };
    nixosConfigurations = let
      makeNixosConfiguration = hostName:
        nixpkgs.lib.nixosSystem {
          modules = [(rootPath + "/nixos/configurations/${hostName}")];
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
          flip genAttrs makeNixosConfiguration
      );
  };
}
