{
  den = {
    hosts.x86_64-linux.Akun = {
      users.david = { };
      deploy.enable = true;
    };
    aspects.Akun.nixos.imports = [ ../_legacy/nixos/configurations/Akun ];
  };
}
