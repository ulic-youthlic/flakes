{
  lib,
  basicArgs,
  buildInputs,
  nativeBuildInputs,
}:
let
  f =
    {
      craneLib,
      lib,
      cargoArtifacts,
      ...
    }@args:
    let
      genInputs = lib.genInputsWith args;
    in
    craneLib.buildPackage (
      basicArgs
      // {
        inherit
          (craneLib.crateNameFromCargoToml {
            cargoToml = "${toString basicArgs.src}/Cargo.toml";
          })
          pname
          version
          ;
        inherit cargoArtifacts;
        buildInputs = genInputs buildInputs;
        nativeBuildInputs = genInputs nativeBuildInputs;
        doCheck = false;
      }
    );
in
with lib;
setFunctionArgs f ((functionArgs f) // (genFunctionArgs (buildInputs ++ nativeBuildInputs)))
