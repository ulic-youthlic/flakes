{
  inputs,
  rootPath,
  config,
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
      ...
    }:
    let
      patchedNixpkgs = lib.nixpkgs-patcher.patchNixpkgs {
        inherit system inputs;
      };
      overlay = config.flake.overlays.default;
      nixpkgsArgs = {
        localSystem = {
          inherit system;
        };
        config = {
          allowUnfree = true;
        };
      };
      original = import patchedNixpkgs nixpkgsArgs;
      added =
        let
          result = overlay result original;
        in
        result;
    in
    {
      _module.args.pkgs = import patchedNixpkgs (
        nixpkgsArgs
        // {
          overlays = [
            (_: _: { inherit lib; })
            overlay
          ];
        }
      );
      packages = lib.filterAttrs (_: lib.isDerivation) (lib.intersectAttrs added pkgs);
      legacyPackages = pkgs;
      devShells.default = pkgs.mkShell {
        name = "nixos-shell";
        packages = with pkgs; [
          nixd
          nil
          typos
          typos-lsp
          just
          nvfetcher
          alejandra
          oxfmt

          lua-language-server
        ];
      };
      checks = lib.concatMapAttrs (name: value: {
        "package-${name}" = value;
      }) self'.packages;
    };
}
