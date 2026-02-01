{inputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  rqbit = inputs.nixpkgs-485603.legacyPackages.${system}.rqbit;
}
