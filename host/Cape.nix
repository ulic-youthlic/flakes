{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = { };
      deploy.enable = true;
    };
    aspects.Cape = {
      includes = with den.aspects; [
        net.openssh
        net.tailscale
      ];
      nixos.imports = [ ../_legacy/nixos/configurations/Cape ];
      provides.alice.homeManager.imports = [ ../_legacy/home/alice/configurations/Cape ];
    };
  };
}
