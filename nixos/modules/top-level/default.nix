{
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops
    stylix.nixosModules.stylix
    disko.nixosModules.disko
    nixvim.nixosModules.nixvim

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
