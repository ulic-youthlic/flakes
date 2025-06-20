{inputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  inherit (inputs.nixpkgs-handbrake.legacyPackages.${system}) handbrake;
}
