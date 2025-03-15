{ inputs, ... }:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  forgejo-lts =
    inputs.nixpkgs-e3e32b642a31e6714ec1b712de8c91a3352ce7e1.legacyPackages."${system}".forgejo-lts;
}
