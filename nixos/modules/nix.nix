{
  inputs,
  config,
  outputs,
  lib,
  ...
}:
{
  config = {
    environment.etc =
      with lib;
      pipe inputs [
        (mapAttrs' (
          name: value:
          lib.nameValuePair "nix/inputs/${name}" {
            source = value;
          }
        ))
      ];
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowInsecurePredicate =
          p:
          builtins.elem (lib.getName p) [
            "electron"

            "immersive-translate"
          ];
        packageOverrides = p: {
          intel-vaapi-driver = p.intel-vaapi-driver.override { enableHybridCodec = true; };
        };
      };
    };
    sops.secrets."access-tokens" = {
      mode = "0444";
    };
    nix = {
      nixPath = [ "/etc/nix/inputs" ];
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
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
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
      registry =
        with lib;
        pipe inputs [
          (filterAttrs (name: _value: name != "nixpkgs"))
          (mapAttrs (
            _name: value: {
              flake = lib.mkForce {
                outPath = value;
              };
            }
          ))
        ];
    };
  };
}
