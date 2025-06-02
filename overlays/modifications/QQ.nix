{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  qq = outputs.packages."${system}".QQ;
}
