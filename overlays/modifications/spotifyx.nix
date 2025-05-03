{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  spotify = outputs.packages."${system}".spotifyx;
}
