{
  den.aspects.nix.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      sops.secrets."access-tokens" = {
        mode = "0444";
      };
      nix = {
        package = pkgs.nixVersions.latest;
        extraOptions = ''
          !include ${config.sops.secrets."access-tokens".path}
        '';
        settings = {
          substituters = [
            "https://cache.nixos.org"
            "https://cache.nixos-cuda.org"
            "https://cache.flox.dev"
            "https://attic.xuyh0120.win/lantian"
            "https://nix-community.cachix.org"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
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
      };
    };
}
