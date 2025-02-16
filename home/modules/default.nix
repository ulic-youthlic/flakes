{
  inputs,
  ...
}:
{
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
    ])
    ++ [
      ./programs
      ./xdg-dirs.nix
    ];

  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
