{
  inputs,
  config,
  ...
}:
{
  perSystem =
    {
      pkgs,
      system,
      lib,
      self',
      ...
    }:
    let
      patchedNixpkgs = inputs.nixpkgs-patcher.lib.patchNixpkgs {
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
          overlays = [ overlay ];
        }
      );
      packages = lib.filterAttrs (_: lib.isDerivation) (lib.intersectAttrs added pkgs);
      legacyPackages = pkgs;
      checks = lib.concatMapAttrs (name: value: {
        "package-${name}" = value;
      }) self'.packages;
    };
}
