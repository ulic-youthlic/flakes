{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Akun = {
      users.david = { };
      deploy.enable = true;
    };
    aspects.Akun = {
      includes = with den.aspects; [
        desktop.backlight
        desktop.kanata
        desktop.obs
        desktop.wshowkeys
        net.openssh
        net.tailscale
      ];
      nixos = {
        imports = [ ../_legacy/nixos/configurations/Akun ];
        users = {
          mutableUsers = true;
          users.david.openssh.authorizedKeys.keyFiles = [ ./Akun/akun.pub ];
        };
      };
      provides.david.includes = with den.aspects; [
        david.niri
      ];
    };
  };
}
