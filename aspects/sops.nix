{ inputs, ... }:
{
  den.aspects.sops = {
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.defaultSopsFile = ../secrets/general.yaml;
      sops.age = {
        keyFile = "/var/sops/key.txt";
        sshKeyPaths = [ ];
        generateKey = false;
      };
    };
    homeManager = {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops = {
        age = {
          keyFile = "/var/sops/key.txt";
          generateKey = false;
        };
        defaultSopsFile = ../secrets/general.yaml;
      };
    };

    # The CLIs for editing secrets, for users who do.
    cli.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          sops
          age
        ];
      };
  };
}
