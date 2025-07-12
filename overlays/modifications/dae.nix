{ inputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  dae = inputs.dae.packages."${system}".dae-unstable;
}
