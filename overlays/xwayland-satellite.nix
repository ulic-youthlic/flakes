{ inputs, ... }: {
  den.overlays.xwayland-satellite =
    { final, prev }: inputs.xwayland-satellite.overlays.default final prev;
}
