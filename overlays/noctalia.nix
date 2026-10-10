{ inputs, ... }: {
  den.overlays.noctalia = { final, prev }: inputs.noctalia.overlays.default final prev;
}
