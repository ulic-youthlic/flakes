{
  den = {
    hosts.x86_64-linux.Tytonidae.users.david = { };
    aspects.Tytonidae = {
      nixos.imports = [ ../_legacy/nixos/configurations/Tytonidae ];
      provides.david.homeManager.imports = [ ../_legacy/home/david/configurations/Tytonidae ];
    };
  };
}
