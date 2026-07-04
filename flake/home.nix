{
  lib,
  inputs,
  self,
  rootPath,
  ...
}:
let
  inherit (self) outputs;
  homeModules =
    (
      with lib;
      pipe (rootPath + "/home") [
        builtins.readDir
        (filterAttrs (_key: value: value == "directory"))
        (filterAttrs (
          key: _value:
          !builtins.elem key [
            "modules"
            "extra"
          ]
        ))
        builtins.attrNames
        (flip genAttrs (name: import (rootPath + "/home/${name}/modules")))
      ]
    )
    // {
      default = import "${toString rootPath}/home/modules";
      extra = import "${toString rootPath}/home/extra";
    };
  makeHomeConfiguration =
    {
      hostName,
      unixName ? "david",
      system ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      home-manager ? inputs.home-manager,
    }:
    {
      "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          localSystem = { inherit system; };
        };
        modules = [
          (rootPath + "/home/${unixName}/configurations/${hostName}")
        ]
        ++ (with homeModules; [
          default
          extra
        ])
        ++ [
          homeModules."${unixName}"
        ]
        ++ [
          {
            lib = { inherit (lib) youthlic; };
          }
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
in
{
  flake = {
    homeConfigurations =
      with lib;
      foldr (a: b: a // b) { } (
        pipe
          [
            # Hostname
          ]
          [ (map (hostName: makeHomeConfiguration { inherit hostName; })) ]
      );
    inherit homeModules;
  };
}
