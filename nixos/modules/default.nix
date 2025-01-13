{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports =
    (with inputs; [
      niri-flake.nixosModules.niri
      nixos-cosmic.nixosModules.default
      home-manager.nixosModules.home-manager
      dae.nixosModules.dae
      sops-nix.nixosModules.sops
    ])
    ++ [
      ./nix.nix
      ./home.nix
      ./sops.nix
      ./dae
      ./openssh.nix
      ./nh.nix
      ./i18n.nix
      ./gui.nix
      ./steam.nix
    ];

  config = {
    nixpkgs = {
      overlays = with outputs.overlays; [
        modifications
        additions
      ];
    };
  };
}
