{ den, inputs, ... }:
{
  den = {
    hosts.x86_64-linux.Akun = {
      users.david = { };
      deploy.enable = true;
    };
    aspects.Akun = {
      includes = with den.aspects; [
        desktop.backlight
        desktop.i18n
        desktop.kanata
        desktop.obs
        desktop.wshowkeys
        net.openssh
        net.tailscale
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
      provides.david.includes = with den.aspects; [
        david.niri
      ];
    };
  };
}
