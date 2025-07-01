{inputs, ...}: {
  imports =
    [
      ./.
    ]
    ++ (with inputs; [
      niri-flake.nixosModules.niri
    ]);
}
