{ outputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  spotifyd = outputs.packages."${system}".spotifyd;
}
