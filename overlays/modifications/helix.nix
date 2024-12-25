{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  helix = inputs.helix.packages."${system}".default;
}
