{outputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  helix = outputs.packages."${system}".helix;
}
