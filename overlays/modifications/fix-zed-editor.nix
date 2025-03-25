{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  zed-editor =
    inputs.nixpkgs-d056063028f6cbe9b99c3a4b52fdad99573db3ab.legacyPackages."${system}".zed-editor;
}
