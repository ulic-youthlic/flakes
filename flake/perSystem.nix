{
  inputs,
  rootPath,
  ...
}: {
  imports = [
    (rootPath + "/treefmt.nix")
  ];
  perSystem = {
    pkgs,
    system,
    lib,
    self',
    ...
  }: let
    inherit (inputs) nixpkgs;
  in {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    devShells.default = pkgs.mkShell {
      name = "nixos-shell";
      packages = with pkgs; [
        nixd
        nil
        typos
        typos-lsp
        just
        nvfetcher
      ];
    };
    legacyPackages = let
      inputsScope = lib.makeScope pkgs.newScope (self: {
        inherit inputs rootPath;
        srcs = self.callPackage (rootPath + "/_sources/generated.nix") {};
      });
    in
      lib.packagesFromDirectoryRecursive {
        inherit (inputsScope) callPackage;
        directory = rootPath + "/pkgs";
      };
    packages = let
      flattenPkgs = path: value:
        if lib.isDerivation value
        then {
          ${lib.concatStringsSep "/" path} = value;
        }
        else if lib.isAttrs value
        then lib.concatMapAttrs (name: flattenPkgs (path ++ [name])) value
        else {};
    in
      flattenPkgs [] self'.legacyPackages;
    checks =
      lib.concatMapAttrs (name: value: {
        "package-${name}" = value;
      })
      self'.packages;
  };
}
