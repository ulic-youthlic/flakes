{ den, ... }:
{
  den = {
    hosts.x86_64-linux.Tytonidae.users.david = { };
    aspects.Tytonidae = {
      includes = with den.aspects; [
        desktop.backlight
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
      nixos = {
        imports = [ ../_legacy/nixos/configurations/Tytonidae ];
        users.users.david = {
          extraGroups = [ "audio" ];
          openssh.authorizedKeys.keyFiles = [ ./Tytonidae/tytonidae.pub ];
        };
      };
      provides.david = {
        includes = with den.aspects; [
          david.niri
          david.radicle
          david.spotify
          shell.ion
          tty.aria2
          tty.awscli
          tty.rustypaste-cli
          virt.kvm
        ];
        homeManager.imports = [ ../_legacy/home/david/configurations/Tytonidae ];
      };
    };
  };
}
