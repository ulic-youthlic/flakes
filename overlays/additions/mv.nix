{ inputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  mv = inputs.nixpkgs-multiverse.multiverse.${system};
}
