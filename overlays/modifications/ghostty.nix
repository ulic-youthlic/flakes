{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  ghostty = inputs.ghostty.packages."${system}".default;
}
