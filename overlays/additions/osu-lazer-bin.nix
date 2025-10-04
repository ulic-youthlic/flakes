{ inputs, ... }:
_final: prev:
let
  inherit (inputs) nix-gaming;
  inherit (prev.stdenv.hostPlatform) system;
in
{
  inherit (nix-gaming.packages.${system}) osu-lazer-bin; # typochecker: disable-line
}
