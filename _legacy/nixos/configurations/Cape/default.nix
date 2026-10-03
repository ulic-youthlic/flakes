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
    users.deploy.enable = true;
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
      juicity.server.enable = true;
      matrix-tuwunel = {
        enable = true;
        serverName = "im.youthlic.social";
      };
      rqbit = {
        enable = true;
        unixName = "alice";
        ratelimitUpload = 0;
        httpHost = "0.0.0.0";
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
