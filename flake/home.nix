{
  outputs,
  rootPath,
}: {
  lib,
  inputs,
  ...
}: let
  homeModules =
    {
      default = import "${toString rootPath}/home/modules";
      extra = import "${toString rootPath}/home/extra";
    }
    // (
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
      |> map (name: {
        name = name;
        value = import "${toString rootPath}/home/${name}/modules";
      })
      |> builtins.listToAttrs
    );
  mkHomeConfig = {
    hostName,
    unixName ? "david",
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    home-manager ? inputs.home-manager,
  }: {
    "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."${system}";
      modules =
        [
          "${toString rootPath}/home/${unixName}/configurations/${hostName}"
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
    homeConfigurations =
      lib.foldr (a: b: a // b) {} (
        map (hostName: mkHomeConfig {inherit hostName;}) [
          "Tytonidae"
          "Akun"
        ]
      )
      // mkHomeConfig {
        hostName = "Cape";
        unixName = "alice";
      };
    inherit homeModules;
  };
}
