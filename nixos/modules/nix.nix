{
  inputs,
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  config = {
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };
    sops.secrets."access-tokens" = {
      mode = "0444";
    };
    nix = {
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      extraOptions = ''
        !include ${config.sops.secrets."access-tokens".path}
      '';
      settings = {
        inherit (outputs.nix.settings) substituters;
        trusted-users = [
          "root"
          "@wheel"
        ];
        trusted-public-keys = [
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        system-features = [
          "kvm"
          "big-parallel"
        ];
        use-xdg-base-directories = true;
        builders-use-substitutes = true;
      };
      package = pkgs.nix;
      registry.sys = lib.mkDefault {
        from = {
          type = "indirect";
          id = "sys";
        };
        flake = inputs.nixpkgs;
      };
    };
  };
}
