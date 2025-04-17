{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  niri-unstable = inputs.niri-flake.packages."${system}".niri-unstable;
  niri-overview = inputs.niri-overview.packages."${system}".niri;
  niri-stable = inputs.niri-flake.packages."${system}".niri-stable;
}
