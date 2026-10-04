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
        desktop.i18n
        desktop.kanata
        desktop.kdeconnect
        desktop.obs
        desktop.steam
        desktop.upower
        desktop.wshowkeys
        hardware.asus
        net.juicity.client
        net.openssh
        net.sing-box
        net.tailscale
        server.garage
        server.miniserve
        server.readest
        server.rqbit
        server.webdav-proxy
        tty.guix
        tty.nix-ld
      ];
      nixos =
        { config, ... }:
        {
          imports = [
            ./Tytonidae/_configuration.nix
          ]
          ++ (with inputs.nixos-hardware.nixosModules; [
            common-hidpi
            common-cpu-intel
            common-gpu-nvidia
            common-pc-laptop
            common-pc-laptop-ssd
            asus-battery
          ])
          ++ [
            inputs.lanzaboote.nixosModules.lanzaboote
            ./Tytonidae/_disk-config.nix
            ./Tytonidae/_filesystem.nix
            ./Tytonidae/_hardware-configuration.nix
            ./Tytonidae/_hardware.nix
            ./Tytonidae/_kanata.nix
            ./Tytonidae/_networking.nix
          ];
          users.users.david = {
            extraGroups = [ "audio" ];
            openssh.authorizedKeys.keyFiles = [ ./Tytonidae/tytonidae.pub ];
          };
          youthlic.programs = {
            miniserve.apps =
              let
                inherit (config.youthlic.programs.miniserve.templates) cinny ariang;
              in
              {
                cinny-1 = cinny { port = 9093; };
                cinny-2 = cinny { port = 9094; };
                cinny-3 = cinny { port = 9095; };
                ariang = ariang { port = 9096; };
              };
            readest = {
              port = 9097;
              environment.SITE_URL = "http://127.0.0.1:9097";
            };
            webdav-proxy = {
              upstream = "https://toi.teracloud.jp";
              allowedOrigins = [ "http://127.0.0.1:9097" ];
            };
            rqbit.ratelimitUpload = 10;
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
