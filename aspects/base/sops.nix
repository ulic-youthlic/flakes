{ inputs, ... }:
{
  den.aspects.base.sops = {
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.defaultSopsFile = ../../secrets/general.yaml;
      sops.age = {
        keyFile = "/var/sops/key.txt";
        sshKeyPaths = [ ];
        generateKey = false;
      };
    };
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        home.packages = (
          with pkgs;
          [
            sops
            age
          ]
        );
        sops = {
          age = {
            keyFile = "/var/sops/key.txt";
            generateKey = false;
          };
          defaultSopsFile = ../../secrets/general.yaml;
        };
      };
  };
}
