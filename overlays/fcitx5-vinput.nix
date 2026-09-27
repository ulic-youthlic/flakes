{ inputs, ... }: {
  den.overlays.fcitx5-vinput = { final, ... }: {
    fcitx5-vinput = inputs.fcitx5-vinput.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
