{outputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  cliphist = outputs.packages."${system}".cliphist';
}
