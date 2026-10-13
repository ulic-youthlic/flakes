{ denOverlay, ... }:
{
  # The bash counterpart of buildGoTool: wraps a body under ./scripts into a
  # writeShellApplication, which supplies the shebang, `set -euo pipefail` and a
  # PATH built from runtimeInputs, then shellchecks the result.
  #
  # Only the body lives in scripts/<pname>.sh — no shebang, no `set -`, no PATH
  # juggling — so the same file is a script a human can read on its own.
  den.overlays.buildBashTool = denOverlay.lib.inject (
    { final }:
    {
      # Selects scripts/<pname>.sh.
      pname,
      # Name of the produced executable; the two differ when the script is a
      # drop-in replacement for another program (pinentry-selector -> pinentry).
      name ? pname,
      runtimeInputs ? [ ],
      runtimeEnv ? null,
      # Replaces @token@ in the body, for values only the caller knows.
      substitutions ? { },
      meta ? { },
    }:
    let
      keys = builtins.attrNames substitutions;
      text = final.lib.replaceStrings (map (k: "@${k}@") keys) (map (
        k: builtins.toString substitutions.${k}
      ) keys) (builtins.readFile ../scripts/${pname}.sh);
    in
    final.writeShellApplication {
      inherit
        name
        runtimeInputs
        runtimeEnv
        text
        ;
      meta = {
        mainProgram = name;
      }
      // meta;
    }
  );
}
