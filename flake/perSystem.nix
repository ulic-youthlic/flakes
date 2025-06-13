{inputs, ...}: let
  rootPath = ./..;
in {
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
    callPackages = lib.callPackagesWith (pkgs // {inherit callPackages inputs rootPath;});
  in {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        nil
        typos
        typos-lsp
        just
        nvfetcher
      ];
    };
    packages = callPackages (rootPath + "/pkgs") {};
    checks = self'.packages;
  };
}
