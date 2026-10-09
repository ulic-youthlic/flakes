{ den, inputs, ... }:
{
  den = {
    hosts.x86_64-linux.Akun = {
      users.david = den.users.david;
      deploy.enable = true;
    };
    aspects.Akun = {
      includes = with den.aspects; [
        niri
        helix
        backlight
        i18n
        kanata
        obs
        wshowkeys
        openssh
        tailscale
        nftables
      ];
      nixos = {
        imports = [
          ./Akun/_configuration.nix
        ]
        ++ (with inputs.nixos-hardware.nixosModules; [
          common-cpu-intel
          common-pc-laptop
          common-pc-laptop-ssd
        ])
        ++ [
          ./Akun/_disk-config.nix
          ./Akun/_hardware-configuration.nix
          ./Akun/_networking.nix
        ];
        users = {
          mutableUsers = true;
          users.david.openssh.authorizedKeys.keyFiles = [ ./Akun/akun.pub ];
        };
      };
    };
  };
}
