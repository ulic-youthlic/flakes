{
  inputs,
  callPackage,
  buildEnv,
  lib,
  pkgs,
}:
let
  inherit (inputs.helix.overlays.default pkgs pkgs) helix;
  runtime = callPackage ./runtime.nix { };
  helix' = helix.overrideAttrs (
    _final: prev:
    let
      helix-runtime = buildEnv {
        name = "helix-runtime";
        paths = [
          runtime
          prev.env.HELIX_DEFAULT_RUNTIME
        ];
      };
    in
    {
      env.HELIX_DEFAULT_RUNTIME = toString helix-runtime;
      cargoBuildFeatures = (prev.cargoBuildFeatures or [ ]) ++ [
        "git"
        "steel"
      ];
    }
  );
in
helix'
// {
  passthru = (helix'.passthru or { }) // {
    languages = lib.pipe "${helix.src}/languages.toml" [
      builtins.readFile
      fromTOML
    ];
  };
}
