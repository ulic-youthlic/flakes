{ inputs, ... }:
final: prev:
let
  inherit (final.stdenv.hostPlatform) system;
in
{
  jujutsu = inputs.jj.packages."${system}".jujutsu.overrideAttrs { doCheck = false; };
}
