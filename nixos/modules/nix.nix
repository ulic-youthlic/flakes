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
    environment.etc =
      inputs
      |> lib.mapAttrs' (
        name: value:
        lib.nameValuePair "nix/inputs/${name}" {
          source = value;
        }
      );
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowInsecurePredicate =
          p:
          builtins.elem (lib.getName p) [
            # for neochat
            "olm"

            "immersive-translate"
          ];
        packageOverrides = p: {
          intel-vaapi-driver = p.intel-vaapi-driver.override { enableHybridCodec = true; };
          onnxruntime = p.onnxruntime.override {
            cudaSupport = false;
            ncclSupport = false;
          };
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
        ];
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ]
        ++ (lib.optional config.lix.enable "pipe-operator")
        ++ (lib.optional (!config.lix.enable) "pipe-operators");
        warn-dirty = false;
        system-features = [
          "kvm"
          "big-parallel"
        ];
        use-xdg-base-directories = true;
        builders-use-substitutes = true;
      };
      package = pkgs.nix;
      registry =
        inputs
        |> lib.filterAttrs (name: _value: name != "nixpkgs")
        |> lib.mapAttrs (
          _name: value: {
            flake = lib.mkForce {
              outPath = value;
            };
          }
        );
    };
  };
}
