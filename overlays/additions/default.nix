{ ... }@args:
final: prev:
let
  inherit (prev) lib;
  overlay-files = [
  ];
  overlay-list = map (file: import file args) overlay-files;
in
(lib.composeManyExtensions overlay-list) final prev
