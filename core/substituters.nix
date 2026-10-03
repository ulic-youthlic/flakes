{ lib, ... }:
{
  # substituters shared in home-manager and nixos configuration
  flake.nix.settings.substituters =
    let
      cachix = x: "https://${x}.cachix.org";
    in
    lib.flatten [
      (cachix "nix-community")
      "https://cache.nixos.org"
      "https://cache.nixos-cuda.org"
      "https://attic.xuyh0120.win/lantian"
    ];
}
