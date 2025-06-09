{
  inputs,
  system,
  callPackage,
  symlinkJoin,
  makeWrapper,
}: let
  inherit (inputs.helix.packages."${system}") helix;
  runtime = callPackage ./runtime.nix {};
in
  symlinkJoin {
    name = "helix-wrapped";
    paths = [helix];
    inherit (helix) meta;
    buildInputs = [
      makeWrapper
    ];
    postBuild = ''
      wrapProgram $out/bin/hx \
      --set HELIX_RUNTIME ${runtime}
    '';
  }
