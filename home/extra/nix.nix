{
  outputs,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
      overlays = [
        outputs.overlays.modifications
        outputs.overlays.additions
      ];
    };
    nix = {
      package = pkgs.nix;
      settings = {
        inherit (outputs.nix.settings) substituters;
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        ];
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        use-xdg-base-directories = true;
      };
      registry.home = lib.mkDefault {
        from = {
          type = "indirect";
          id = "home";
        };
        flake = inputs.nixpkgs;
      };
    };
  };
}
