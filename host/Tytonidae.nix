{
  den,
  lib,
  inputs,
  kdl,
  ...
}:
{
  den = {
    hosts.x86_64-linux.Tytonidae = {
      cudaSupport = true;
      users.david = lib.recursiveUpdate den.users.david {
        awscli.endpoint = "http://localhost:8491";
        radicle.sops = {
          secret = "radicle/Tytonidae";
          path = "/home/david/.config/sops-nix/secrets/radicle/Tytonidae";
        };
        rustypaste-cli = {
          url = den.hosts.x86_64-linux.Cape.rustypaste.url;
          sops = {
            auth.secret = "rustypaste/auth";
            delete.secret = "rustypaste/delete";
          };
        };
      };
      incus.httpsAddress = "127.0.0.1:8443";
      niri.extraConfig =
        let
          inherit (kdl.dsl) n;
        in
        kdl.formats.v1 [
          (n "debug" [
            (n "render-drm-device" "/dev/dri/by-path/pci-0000:00:02.0-render") # Intel
            (n "ignore-drm-device" "/dev/dri/by-path/pci-0000:01:00.0-render") # NVIDIA
          ])
        ];
      miniserve.apps = {
        cinny-1 = {
          template = "cinny";
          port = 9093;
        };
        cinny-2 = {
          template = "cinny";
          port = 9094;
        };
        cinny-3 = {
          template = "cinny";
          port = 9095;
        };
        ariang = {
          template = "ariang";
          port = 9096;
        };
      };
      readest = rec {
        port = 9097;
        listen = "127.0.0.1";
        webdavProxy = {
          enable = true;
          upstream = "https://toi.teracloud.jp";
          allowedOrigins = [ "http://${listen}:${toString port}" ];
        };
      };
      rqbit = {
        ratelimitUpload = 10;
        sops = {
          secret = "rqbit.secrets.env";
          path = "/run/secrets/rqbit.secrets.env";
        };
      };
    };
    aspects.Tytonidae = {
      includes = with den.aspects; [
        niri
        helix
        backlight
        i18n
        kanata
        kdeconnect
        obs
        steam
        bitwarden
        prismlauncher
        upower
        wshowkeys
        asus
        juicity.client
        openssh
        sing-box
        tailscale
        garage
        miniserve
        readest
        rqbit
        guix
        nix-ld
        nftables
      ];
      nixos = {
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
      };
      provides.david = {
        includes = with den.aspects; [
          radicle
          spotify
          kdenlive
          ion
          aria2
          awscli
          rustypaste-cli
          incus
        ];
        homeManager =
          { pkgs, ... }:
          {
            home.packages = with pkgs; [
              android-tools
            ];
          };
      };
    };
  };
}
