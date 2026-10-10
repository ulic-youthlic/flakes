{ inputs, config, ... }:
{
  # The flake's one nixpkgs instance: the nixpkgs-patch-* inputs applied,
  # configured here. perSystem uses it as `pkgs` and aspects/nixpkgs.nix
  # gives it to every host, so modules must not set nixpkgs.config or
  # nixpkgs.overlays.
  perSystem =
    { system, lib, ... }:
    {
      _module.args.pkgs = import (inputs.nixpkgs-patcher.lib.patchNixpkgs { inherit system inputs; }) {
        localSystem = {
          inherit system;
        };
        overlays = [ config.flake.overlays.default ];
        config = {
          allowUnfree = true;
          allowInsecurePredicate =
            p:
            builtins.elem (lib.getName p) [
              "electron"

              "radicle-node"
            ];
          packageOverrides = p: {
            intel-vaapi-driver = p.intel-vaapi-driver.override { enableHybridCodec = true; };
          };
        };
      };
    };

  den.schema.host =
    { lib, ... }:
    {
      options.cudaSupport = lib.mkEnableOption "CUDA in the host's packages (`pkgs.pkgsCuda`)";
    };
}
