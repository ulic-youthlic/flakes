{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  imports = [
    outputs.nixosModules.default
  ]
  ++ (lib.youthlic.loadImports ./.);

  youthlic = {
    containers.interface = "ens3";
    programs = {
      rustypaste = {
        enable = true;
        url = "https://paste.youthlic.social";
      };
      caddy = {
        enable = true;
        baseDomain = "youthlic.social";
        radicle-explorer.enable = true;
        outer-wilds-text-adventure.enable = true;
        garage = {
          enable = true;
          target = "100.73.250.25";
        };
      };
      matrix-tuwunel = {
        enable = true;
        serverName = "im.youthlic.social";
      };
    };
  };

  time.timeZone = "America/New_York";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    wget
    git
    vim-full
    steelix
    btop
  ];

  boot.loader.grub = {
    enable = true;
  };
  nix = {
    settings = {
      system-features = [ "gccarch-ivybridge" ];
    };
  };

}
