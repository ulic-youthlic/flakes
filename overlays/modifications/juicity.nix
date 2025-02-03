{ outputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  juicity = outputs.packages."${system}".juicity;
}
