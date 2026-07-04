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
    home-manager = {
      enable = true;
      unixName = "alice";
      hostName = "Cape";
    };
    users.deploy.enable = true;
    containers.interface = "ens3";
    programs = {
      rustypaste = {
        enable = true;
        url = "https://paste.youthlic.social";
      };
      openssh.enable = true;
      tailscale.enable = true;
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
      juicity.server.enable = true;
      matrix-tuwunel = {
        enable = true;
        serverName = "im.youthlic.social";
      };
      rqbit = {
        enable = true;
        unixName = "alice";
        ratelimitUpload = 0;
        httpHost = "100.76.229.45";
      };
    };
  };

  programs.gnupg.agent = {
    enable = true;
  };

  networking.hostName = "Cape";

  time.timeZone = "America/New_York";

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    wget
    git
    vim
    helix
    btop
  ];

  environment.variables.EDITOR = "hx";
  services.dbus.implementation = "broker";

  boot.loader.grub = {
    enable = true;
  };
  nix = {
    settings = {
      system-features = [ "gccarch-ivybridge" ];
    };
  };

  system.stateVersion = "24.11";
}
