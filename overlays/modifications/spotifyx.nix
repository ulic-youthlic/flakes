{outputs, ...}: final: prev: let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in {
  spotify = outputs.packages."${system}".spotifyx;
}
