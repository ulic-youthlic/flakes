{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = with inputs; [
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    catppuccin.nixosModules.catppuccin

    ./..
  ];

  config = {
    nixpkgs = {
      overlays = lib.singleton outputs.overlays.default;
    };
    environment.systemPackages = with pkgs; [
      deploy-rs
    ];
  };
}
