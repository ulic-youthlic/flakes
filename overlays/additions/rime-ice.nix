{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  rime-ice = outputs.packages."${system}".rime-ice;
}
