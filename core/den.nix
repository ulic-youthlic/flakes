{ inputs, lib, ... }:
{
  imports = [ inputs.den.flakeModules.default ];

  options.den.users = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Named user records for hosts to select and override.";
  };

  config = {
    den.schema.user.classes = lib.mkDefault [ "homeManager" ];

    den.schema.hm-host.includes = [
      {
        # den applies hm-host includes at host scope and again per user;
        # the key makes the module system import this only once.
        nixos.imports = [
          {
            key = "youthlic:home-manager-settings";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
            };
          }
        ];
      }
    ];

    den.schema.host =
      { config, lib, ... }:
      {
        # Build NixOS hosts from nixpkgs with the nixpkgs-patch-* inputs
        # applied. mkDefault: still beats den's option default, but leaves
        # room for a per-host `instantiate` (the option is raw, so two
        # equal-priority definitions would fail to merge).
        instantiate = lib.mkIf (config.class == "nixos") (
          lib.mkDefault (
            args:
            inputs.nixpkgs-patcher.lib.nixosSystem (
              args
              // {
                nixpkgsPatcher = {
                  inherit inputs;
                  inherit (config) system;
                };
              }
            )
          )
        );
      };
  };
}
