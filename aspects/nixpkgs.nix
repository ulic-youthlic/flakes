{ withSystem, ... }:
{
  # Hosts share the flake's nixpkgs instance (core/nixpkgs.nix).
  den.aspects.nixpkgs.nixos =
    { config, host, ... }:
    {
      nixpkgs.pkgs = withSystem host.system (
        { pkgs, ... }: if host.cudaSupport then pkgs.pkgsCuda else pkgs
      );
      # NixOS already rejects nixpkgs.config next to nixpkgs.pkgs, but would
      # quietly build a second instance for nixpkgs.overlays.
      assertions = [
        {
          assertion = config.nixpkgs.overlays == [ ];
          message = "Add overlays under overlays/ (core/nixpkgs.nix), not nixpkgs.overlays.";
        }
      ];
    };
}
