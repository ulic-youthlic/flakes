{ inputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  inherit (inputs.nixpkgs-b12141ef619e0a9c1c84dc8c684040326f27cdcc.legacyPackages.${system})
    clash-verge-rev
    ;
}
