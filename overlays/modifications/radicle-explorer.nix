{outputs, ...}: final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
in {
  radicle-explorer = outputs.packages."${system}".radicle-explorer;
}
