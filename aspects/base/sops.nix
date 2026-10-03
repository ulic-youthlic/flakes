{ inputs, ... }:
{
  den.aspects.base.sops.nixos = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.defaultSopsFile = ../../secrets/general.yaml;
    sops.age = {
      keyFile = "/var/sops/key.txt";
      sshKeyPaths = [ ];
      generateKey = false;
    };
  };
}
