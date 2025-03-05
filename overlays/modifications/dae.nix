{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  dae = inputs.dae.packages."${system}".dae-unstable;
}
