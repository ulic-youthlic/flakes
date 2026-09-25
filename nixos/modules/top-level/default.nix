{
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = with inputs; [
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    catppuccin.nixosModules.catppuccin

    ./..
  ];

  config = {
    nixpkgs = {
      overlays = with outputs.overlays; [
        modifications
        additions
      ];
    };
    environment.systemPackages = with pkgs; [
      deploy-rs
    ];
  };
}
