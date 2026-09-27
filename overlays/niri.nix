{ inputs, ... }: {
  den.overlays.niri = { final, prev }: inputs.niri.overlays.default final prev;
}
