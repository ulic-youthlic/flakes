{
  lib,
  inputs,
  config,
  den,
  flake-parts-lib,
  ...
}:
let
  inherit (inputs) deploy-rs;
  inherit (config.flake) nixosConfigurations;
  hosts = lib.concatMap lib.attrValues (lib.attrValues config.den.hosts);
  # deploy-rs's activation helpers over the host's own pkgs, with nixpkgs'
  # deploy-rs (the CLI aspects/nix.nix installs) providing activate-rs.
  deployLib =
    pkgs:
    (deploy-rs.overlays.default (pkgs // { deploy-rs.deploy-rs = pkgs.deploy-rs; }) pkgs).deploy-rs.lib;
  mkDeployNode = host: {
    "${host.name}" = {
      inherit (host.deploy) hostname;
      # Account defined by den.aspects.deploy.
      sshUser = "deploy";
      interactiveSudo = true;
      profiles = {
        system = {
          user = "root";
          path =
            let
              system = nixosConfigurations."${host.name}";
            in
            (deployLib system.pkgs).activate.nixos system;
        };
      };
    };
  };
in
{
  imports = [
    {
      # Hosts deployed with deploy-rs get the account it logs in as.
      den.schema.host.includes = [
        (
          { host, ... }:
          lib.optionalAttrs host.deploy.enable {
            includes = [ den.aspects.deploy ];
          }
        )
      ];
    }
  ];
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      deploy = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
    };
  };
  config = {
    den.schema.host =
      { config, lib, ... }:
      {
        options.deploy = {
          enable = lib.mkEnableOption "deploying this host with deploy-rs";
          hostname = lib.mkOption {
            type = lib.types.str;
            default = config.hostName;
            description = "Address deploy-rs connects to over SSH.";
          };
        };
      };
    flake.deploy.nodes = lib.pipe hosts [
      (lib.filter (host: host.deploy.enable))
      (map mkDeployNode)
      lib.mergeAttrsList
    ];
  };
}
