{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  inherit (outputs.packages."${system}") TrackersListCollection;
}
