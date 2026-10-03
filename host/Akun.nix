{
  den = {
    hosts.x86_64-linux.Akun = {
      users.david = { };
      deploy.enable = true;
    };
    aspects.Akun = {
      nixos.imports = [ ../_legacy/nixos/configurations/Akun ];
      provides.david.homeManager.imports = [ ../_legacy/home/david/configurations/Akun ];
    };
  };
}
