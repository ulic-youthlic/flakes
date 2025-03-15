{ outputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  rime-ice = outputs.packages."${system}".rime-ice;
}
