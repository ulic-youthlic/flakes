{ outputs, ... }:
_final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  prismlauncher = outputs.packages.${system}.prismlauncher';
}
