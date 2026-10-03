{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Tytonidae.users.david = { };
    aspects.Tytonidae = {
      includes = with den.aspects; [
        desktop.kanata
        desktop.kdeconnect
        desktop.obs
        desktop.steam
        desktop.upower
        desktop.wshowkeys
        net.openssh
        net.tailscale
        tty.guix
        tty.nix-ld
      ];
      nixos.imports = [ ../_legacy/nixos/configurations/Tytonidae ];
      provides.david.homeManager.imports = [ ../_legacy/home/david/configurations/Tytonidae ];
    };
  };
}
