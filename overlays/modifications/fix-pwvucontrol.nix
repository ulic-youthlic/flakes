{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  pwvucontrol =
    inputs.nixpkgs-845dc1e9cbc2e48640b8968af58b4a19db67aa8f.legacyPackages."${system}".pwvucontrol;
}
