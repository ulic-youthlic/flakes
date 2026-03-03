{inputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  guix = inputs.nixpkgs-0182a361324364ae3f436a63005877674cf45efb.legacyPackages.${system}.guix;
}
