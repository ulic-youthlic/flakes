{
  inputs,
  outputs,
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
      stylix.nixosModules.stylix
      disko.nixosModules.disko
    ])
    ++ [
      ./nix.nix
      ./home.nix
      ./sops.nix
      ./dae
      ./openssh.nix
      ./nh.nix
      ./i18n.nix
      ./gui
      ./steam.nix
      ./tailscale.nix
      ./kanata.nix
      ./kvm.nix
      ./open-webui.nix
      ./transmission.nix
      ./caddy.nix
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
