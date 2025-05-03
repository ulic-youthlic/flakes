{outputs}: {
  lib,
  inputs,
  flake-parts-lib,
  ...
}: let
  mkDeployNode = {
    hostName,
    unixName ? "deploy",
    system ? "x86_64-linux",
    sshName ? hostName,
  }: {
    "${hostName}" = {
      hostname = "${sshName}";
      sshUser = "${unixName}";
      interactiveSudo = true;
      profiles = {
        system = {
          user = "root";
          path =
            inputs.deploy-rs.lib."${system}".activate.nixos
            outputs.nixosConfigurations."${hostName}";
        };
      };
    };
  };
in {
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      deploy = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
    };
  };
  config = {
    flake.deploy.nodes =
      [
        "Cape"
        "Akun"
      ]
      |> map (
        hostName:
          mkDeployNode {
            inherit hostName;
          }
      )
      |> lib.foldr (a: b: a // b) {};
  };
}
