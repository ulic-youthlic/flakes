{
  rootPath,
  outputs,
}: {inputs, ...}: let
  defaultNixosModule = import (rootPath + "/nixos/modules");
  inherit (inputs.nixpkgs) lib;
in {
  flake = {
    nixosModules.default = defaultNixosModule;
    nixosConfigurations = let
      nixosConfigDir = rootPath + "/nixos/configurations";
      makeNixConfiguration = hostName:
        lib.nixosSystem {
          modules =
            [defaultNixosModule]
            ++ [
              (
                let
                  dirPath = nixosConfigDir + "/${hostName}";
                  filePath = nixosConfigDir + "/${hostName}.nix";
                in
                  if builtins.pathExists dirPath
                  then dirPath
                  else filePath
              )
            ];
          specialArgs = {
            inherit inputs outputs rootPath;
          };
        };
    in
      nixosConfigDir
      |> builtins.readDir
      |> builtins.attrNames
      |> map (f: lib.removeSuffix ".nix" f)
      |> map (name: {
        inherit name;
        value = makeNixConfiguration name;
      })
      |> builtins.listToAttrs;
  };
}
