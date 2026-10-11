{ inputs, ... }: {
  den.aspects.flake-registry.nixos = { lib, ... }: {
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
    nix = {
      settings.nix-path = [ "/etc/nix/inputs" ];
      registry =
        (lib.pipe inputs [
          (lib.filterAttrs (name: _value: name != "nixpkgs"))
          (lib.mapAttrs (
            _name: value: {
              flake = lib.mkForce {
                outPath = value;
              };
            }
          ))
        ])
        // {
          p = {
            flake = {
              outPath = ../.;
            };
          };
        };
    };
  };
}
