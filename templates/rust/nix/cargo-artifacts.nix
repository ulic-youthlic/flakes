{
  lib,
  basicArgs,
  buildInputs,
  nativeBuildInputs,
}: let
  f = {
    craneLib,
    lib,
    ...
  } @ args: let
    genInputs = lib.genInputsWith args;
  in
    craneLib.buildDepsOnly (
      basicArgs
      // {
        buildInputs = genInputs buildInputs;
        nativeBuildInputs = genInputs nativeBuildInputs;
      }
    );
in
  with lib;
    setFunctionArgs f ((functionArgs f) // (genFunctionArgs (buildInputs ++ nativeBuildInputs)))
