{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.youthlic.lix;
in
{
  options = {
    youthlic.lix = {
      enable = lib.mkEnableOption "lix";
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (lib.mkBefore (
        final: _prev: {
          inherit (final.lixPackageSets.latest)
            nixpkgs-review
            nixpkgs-reviewFull
            nurl
            nix-update
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        }
      ))
    ];
    nix.package = pkgs.lixPackageSets.latest.lix;
  };
}
