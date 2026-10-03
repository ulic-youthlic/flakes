{
  inputs,
  config,
  self,
  lib,
  ...
}:
let
  # Arguments the legacy NixOS modules still expect. Dropped once every
  # module has become an aspect.
  legacySpecialArgs = {
    inherit inputs;
    inherit (self) outputs;
    inherit (config.flake) lib;
    rootPath = ../.;
  };
in
{
  imports = [ inputs.den.flakeModules.default ];

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
            sharedModules = [ ../_legacy/home/modules ];
          };
        }
      ];
    }
  ];

  den.schema.host =
    { config, lib, ... }:
    {
      # mkDefault: still beats den's option default, but leaves room for a
      # per-host `instantiate` (the option is raw, so two equal-priority
      # definitions would fail to merge).
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
              specialArgs = legacySpecialArgs;
            }
          )
        )
      );
    };
}
