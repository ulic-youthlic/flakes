{ inputs, ... }: {
  den.overlays.spicetify = { final }: {
    spicePkgs = inputs.spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};
  };
}
