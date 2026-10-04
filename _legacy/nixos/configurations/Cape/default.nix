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
