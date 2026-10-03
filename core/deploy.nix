{
  lib,
  inputs,
  config,
  flake-parts-lib,
  ...
}:
let
  inherit (inputs) deploy-rs;
  inherit (config.flake) nixosConfigurations;
  hosts = lib.concatMap lib.attrValues (lib.attrValues config.den.hosts);
  mkDeployNode = host: {
    "${host.name}" = {
      inherit (host.deploy) hostname sshUser;
      interactiveSudo = true;
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib."${host.system}".activate.nixos nixosConfigurations."${host.name}";
        };
      };
    };
  };
in
{
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
          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "deploy";
            description = "User deploy-rs logs in as before escalating to root.";
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
