{ inputs, ... }:
{
  den.overlays.mv = { prev }: {
    mv = inputs.nixpkgs-multiverse.multiverse.${prev.stdenv.hostPlatform.system};
  };
}
