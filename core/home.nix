{
  lib,
  config,
  inputs,
  self,
  ...
}:
let
  inherit (self) outputs;
  rootPath = ../.;
  homeModules =
    (
      with lib;
      pipe (rootPath + "/_legacy/home") [
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
        (flip genAttrs (name: import (rootPath + "/_legacy/home/${name}/modules")))
      ]
    )
    // {
      default = import "${toString rootPath}/_legacy/home/modules";
      extra = import "${toString rootPath}/_legacy/home/extra";
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
          (rootPath + "/_legacy/home/${unixName}/configurations/${hostName}")
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
            lib = { inherit (config.flake.lib) youthlic; };
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
  imports = [ inputs.home-manager.flakeModules.home-manager ];
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
