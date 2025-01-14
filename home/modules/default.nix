{ inputs, lib, ... }:
{
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
    ])
    ++ [
      ./nix.nix
      ./helix
      ./gpg
      ./git.nix
      ./shell
      ./ghostty.nix
      ./foot
      ./starship
      ./sops.nix
      ./firefox.nix
    ];

  options = {
    youthlic.nixos.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        whether the os is nixos
      '';
    };
  };
  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
