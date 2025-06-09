{
  lib,
  inputs,
  self,
  ...
}: let
  rootPath = ./..;
  inherit (self) outputs;
  homeModules =
    (
      (rootPath + "/home")
      |> builtins.readDir
      |> lib.filterAttrs (key: value: value == "directory")
      |> lib.filterAttrs (
        key: value:
          !builtins.elem key [
            "modules"
            "extra"
          ]
      )
      |> builtins.attrNames
      |> (with lib; flip genAttrs (name: import (rootPath + "/home/${name}/modules")))
    )
    // {
      default = import "${toString rootPath}/home/modules";
      extra = import "${toString rootPath}/home/extra";
    };
  makeHomeConfiguration = {
    hostName,
    unixName ? "david",
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    home-manager ? inputs.home-manager,
  }: {
    "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
      };
      modules =
        [
          (rootPath + "/home/${unixName}/configurations/${hostName}")
        ]
        ++ (with homeModules; [
          default
          extra
        ])
        ++ [
          homeModules."${unixName}"
        ];
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          unixName
          hostName
          system
          rootPath
          ;
      };
    };
  };
in {
  flake = {
    homeConfigurations = lib.foldr (a: b: a // b) {} (
      [
        # Hostname
      ]
      |> map (hostName: makeHomeConfiguration {inherit hostName;})
    );
    inherit homeModules;
  };
}
