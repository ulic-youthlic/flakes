{
  inputs,
  system,
  callPackage,
  symlinkJoin,
  makeWrapper,
  lib,
}: let
  inherit (inputs.helix.packages."${system}") helix;
  helixWithPassthru =
    helix
    // {
      passthru =
        helix.passthru
        // {
          languages = lib.pipe "${helix.src}/languages.toml" [
            builtins.readFile
            builtins.fromTOML
          ];
        };
    };
  runtime = callPackage ./runtime.nix {};
in
  symlinkJoin {
    name = "helix-wrapped";
    paths = [helixWithPassthru];
    inherit (helixWithPassthru) meta;
    buildInputs = [
      makeWrapper
    ];
    postBuild = ''
      wrapProgram $out/bin/hx \
      --set HELIX_RUNTIME ${runtime}
    '';
    passthru =
      helixWithPassthru.passthru
      // {
        helix-unwrapped = helixWithPassthru;
      };
  }
