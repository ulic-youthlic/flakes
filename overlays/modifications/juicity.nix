{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  juicity = outputs.packages."${system}".juicity;
}
