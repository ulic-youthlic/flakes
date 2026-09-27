{ inputs, ... }: {
  den.overlays.helix.helix =
    {
      runtime,
      final,
      prev,
    }:
    {
      helix =
        let
          inherit (inputs.helix.overlays.helix final prev) helix;
        in
        helix.overrideAttrs (
          _finalAttr: prevAttr:
          let
            helix-runtime' = prev.buildEnv {
              name = "helix-runtime";
              paths = [
                runtime
                prevAttr.env.HELIX_DEFAULT_RUNTIME
              ];
            };
          in
          {
            env.HELIX_DEFAULT_RUNTIME = toString helix-runtime';
            cargoBuildFeatures = (prevAttr.cargoBuildFeatures or [ ]) ++ [
              "git"
              "steel"
            ];
            passthru = prevAttr.passthru or { } // {
              languages = prev.lib.pipe "${helix.src}/languages.toml" [
                builtins.readFile
                fromTOML
              ];
            };
          }
        );
    };
}
