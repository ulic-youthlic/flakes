{ denOverlay, ... }: {
  den.overlays.nvSources = denOverlay.lib.inject (
    { prev }: prev.callPackage ../_sources/generated.nix { }
  );
}
