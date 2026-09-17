{ inputs, ... }: final: prev: {
  fcitx5-vinput = inputs.fcitx5-vinput.packages.${final.stdenv.hostPlatform.system}.default;
}
