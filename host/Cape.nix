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
      nixos = {
        imports = [ ../_legacy/nixos/configurations/Cape ];
        users = {
          mutableUsers = false;
          users.alice.openssh.authorizedKeys.keyFiles = [ ./Cape/cape.pub ];
        };
      };
    };
  };
}
