{inputs, ...}: {
  imports =
    (with inputs; [
      niri-flake.homeModules.niri
      stylix.homeManagerModules.stylix
      chaotic.homeManagerModules.default
    ])
    ++ [
      ./nix.nix
    ];
}
