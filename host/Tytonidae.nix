{ den, inputs, ... }:
let
  inherit (inputs.nix-kdl.kdl.dsl) n;
in
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
        homeManager =
          { pkgs, ... }:
          {
            youthlic.programs.awscli.url = "http://localhost:8491";
            david.programs.niri.config = [
              (n "debug" [
                (n "render-drm-device" "/dev/dri/by-path/pci-0000:00:02.0-render") # Intel
                (n "ignore-drm-device" "/dev/dri/by-path/pci-0000:01:00.0-render") # NVIDIA
              ])
            ];
            home.packages = with pkgs; [
              kdePackages.kdenlive
              android-tools
            ];
          };
      };
    };
  };
}
