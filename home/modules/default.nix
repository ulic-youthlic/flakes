{inputs, ...}: {
  imports =
    (with inputs; [
      sops-nix.homeManagerModules.sops
      betterfox-nix.homeManagerModules.betterfox
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
