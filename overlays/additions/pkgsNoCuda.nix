{ inputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  pkgsNoCuda = inputs.nixpkgs.legacyPackages.${system};
}
