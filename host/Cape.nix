{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Cape = {
      users.alice = { };
      deploy.enable = true;
    };
    aspects.Cape = {
      includes = with den.aspects; [
        net.juicity.server
        net.openssh
        net.tailscale
        server.rqbit
      ];
      nixos = {
        imports = [ ../_legacy/nixos/configurations/Cape ];
        users = {
          mutableUsers = false;
          users.alice.openssh.authorizedKeys.keyFiles = [ ./Cape/cape.pub ];
        };
        youthlic.programs.rqbit = {
          ratelimitUpload = 0;
          httpHost = "0.0.0.0";
        };
      };
    };
  };
}
