{
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports =
    (with inputs; [
      niri-flake.nixosModules.niri
      nixos-cosmic.nixosModules.default
      home-manager.nixosModules.home-manager
      dae.nixosModules.dae
      sops-nix.nixosModules.sops
      stylix.nixosModules.stylix
      disko.nixosModules.disko
      lix-module.nixosModules.default
    ])
    ++ [
      ./containers
      ./deploy
      ./nix.nix
      ./home.nix
      ./sops.nix
      ./i18n.nix
      ./gui
      ./programs
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
