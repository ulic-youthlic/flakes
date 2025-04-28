{inputs, ...}: {
  imports =
    (with inputs; [
      niri-flake.homeModules.niri
      stylix.homeManagerModules.stylix
    ])
    ++ [
      ./nix.nix
    ];
}
