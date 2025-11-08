{inputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  neovim-nightly = inputs.neovim-nightly.packages.${system}.neovim;
}
