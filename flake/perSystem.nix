{
  inputs,
  rootPath,
  ...
}:
{
  imports = [
    (rootPath + "/treefmt.nix")
  ];
  perSystem =
    {
      pkgs,
      system,
      lib,
      self',
      inputs',
      ...
    }:
    let
      inherit (inputs) nixpkgs;
    in
    {
      _module.args.pkgs = import nixpkgs {
        localSystem = { inherit system; };
        config = {
          allowUnfree = true;
        };
        overlays = [ (_final: _prev: { inherit lib; }) ];
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
          nixfmt-rfc-style

          lua-language-server
        ];
      };
      legacyPackages =
        let
          inputsScope = lib.makeScope pkgs.newScope (self: {
            inherit inputs rootPath;
            srcs = self.callPackage (rootPath + "/_sources/generated.nix") { };
            inherit (inputs'.nixvim.legacyPackages) makeNixvim makeNixvimWithModule;
            neovim_git = inputs'.neovim-nightly.packages.default;
          });
        in
        inputsScope.overrideScope (
          final: _prev:
          lib.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            directory = rootPath + "/pkgs";
          }
        );
      packages =
        let
          flattenPkgs =
            path: value:
            if lib.isDerivation value then
              {
                ${lib.concatStringsSep ":" path} = value;
              }
            else if lib.isAttrs value then
              lib.concatMapAttrs (name: flattenPkgs (path ++ [ name ])) value
            else
              { };
        in
        flattenPkgs [ ] (
          lib.removeAttrs self'.legacyPackages [
            "inputs"

            "srcs"

            "rootPath"

            "makeNixvim"
            "makeNixvimWithModule"

            "newScope"
            "overrideScope"
            "packages"
            "callPackage"
          ]
        );
      checks = lib.concatMapAttrs (name: value: {
        "package-${name}" = value;
      }) self'.packages;
    };
}
