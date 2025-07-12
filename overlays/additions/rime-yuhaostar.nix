{ outputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  inherit (outputs.packages.${system}) rime-yuhaostar;
}
