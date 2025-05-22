{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  wshowkeys = outputs.packages.${system}.wshowkeys-mao;
}
