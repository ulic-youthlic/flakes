{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./forgejo.nix
    ./networking.nix
    ./stylix.nix
    ./hardware-configuration.nix
    ./users
    ./disko-config.nix
    ./miniflux.nix
    ./radicle.nix

    outputs.nixosModules.default
  ];

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
      };
      juicity.server.enable = true;
    };
  };

  lix.enable = false;

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
      system-features = ["gccarch-ivybridge"];
    };
  };

  system.stateVersion = "24.11";
}
