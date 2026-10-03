{ inputs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-patcher nix-kdl;
  nixpkgs-lib = nixpkgs.lib;
in
{
  # Extended lib handed to the legacy NixOS and home-manager modules.
  flake.lib = nixpkgs-lib.extend (
    final: prev:
    nixpkgs-lib.recursiveUpdate {
      nixpkgs-patcher = nixpkgs-patcher.lib;
      nix-kdl = nix-kdl.kdl;
    } (import ../_legacy/lib final prev)
  );
}
