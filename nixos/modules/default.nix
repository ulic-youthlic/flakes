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
