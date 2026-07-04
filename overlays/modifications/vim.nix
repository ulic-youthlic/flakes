{ outputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  vim = outputs.packages.${system}.vim';
}
