{inputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  inherit (inputs.nixpkgs-hurl.legacyPackages.${system}) hurl;
}
