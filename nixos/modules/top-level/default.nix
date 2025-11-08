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
    lix-module.nixosModules.default
    chaotic.nixosModules.default
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
    system.rebuild.enableNg = true;
    environment.systemPackages = with pkgs; [
      deploy-rs
    ];
  };
}
