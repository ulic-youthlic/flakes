{ config, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      # The derivations the overlays add (or replace).
      packages = lib.filterAttrs (_: lib.isDerivation) (
        lib.intersectAttrs (config.flake.overlays.default pkgs pkgs) pkgs
      );
      legacyPackages = pkgs;
      checks = lib.concatMapAttrs (name: value: {
        "package-${name}" = value;
      }) self'.packages;
    };
}
