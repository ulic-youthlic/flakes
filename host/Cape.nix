{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = { };
      deploy.enable = true;
    };
    aspects.Cape.nixos.imports = [ ../_legacy/nixos/configurations/Cape ];
  };
}
