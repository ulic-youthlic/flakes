{ inputs, ... }: {
  den.overlays.nur = { final, prev }: inputs.nur.overlays.default final prev;
}
