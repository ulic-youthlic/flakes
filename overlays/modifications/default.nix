{ ... }@args:
final: prev:
let
  inherit (prev) lib;
  overlay-files = [
    ./spotify.nix
    ./niri.nix
    ./ghostty.nix
    ./juicity.nix
    ./dae.nix
  ];
  overlay-list = map (file: import file args) overlay-files;
in
(lib.composeManyExtensions overlay-list) final prev
