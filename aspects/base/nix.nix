{ inputs, self, ... }:
{
  den.aspects.base.nix.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
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
      environment.systemPackages = with pkgs; [
        deploy-rs
      ];
      sops.secrets."access-tokens" = {
        mode = "0444";
      };
      nix = {
        package = pkgs.nixVersions.latest;
        extraOptions = ''
          !include ${config.sops.secrets."access-tokens".path}
        '';
        settings = {
          nix-path = [ "/etc/nix/inputs" ];
          inherit (self.nix.settings) substituters;
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
          (
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
            ]
          )
          // {
            p = {
              flake = {
                outPath = ../..;
              };
            };
          };
      };
    };
}
