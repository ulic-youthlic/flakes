{ inputs, ... }: {
  den.overlays.linux-cachyos = { final, prev }: inputs.nix-cachyos-kernel.overlays.pinned final prev;
}
