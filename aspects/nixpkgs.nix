{ withSystem, ... }:
{
  # Hosts share the flake's nixpkgs instance (core/nixpkgs.nix).
  den.aspects.nixpkgs.nixos =
    { host, ... }:
    {
      nixpkgs.pkgs = withSystem host.system (
        { pkgs, ... }: if host.cudaSupport then pkgs.pkgsCuda else pkgs
      );
    };
}
