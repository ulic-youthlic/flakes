{
  den.overlays.OuterWildsTextAdventure =
    { nvSources, prev }:
    let
      inherit (nvSources.OuterWildsTextAdventure) src date version;
    in
    {
      OuterWildsTextAdventure = prev.buildNpmPackage {
        pname = "OuterWildsTextAdventure";
        version = "0-unstable.${date}-git${version}";
        inherit src;

        npmDeps = prev.importNpmLock {
          npmRoot = src;
        };

        npmBuildScript = "bundle";

        installPhase = # bash
          ''
            runHook preInstall

            mkdir -p $out
            cp -rt $out/ index.html data p5.min.js bundle.js bundle.js.map

            runHook postInstall
          '';
        npmConfigHook = prev.importNpmLock.npmConfigHook;
      };
    };
}
