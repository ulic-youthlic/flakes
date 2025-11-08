{
  srcs,
  buildNpmPackage,
  importNpmLock,
  ...
}: let
  inherit (srcs.OuterWildsTextAdventure) src date version;
in
  buildNpmPackage {
    pname = "OuterWildsTextAdventure";
    version = "0-unstable.${date}-git${version}";
    inherit src;

    npmDeps = importNpmLock {
      npmRoot = src;
    };

    npmBuildScript = "bundle";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -rt $out/ index.html data p5.min.js bundle.js bundle.js.map

      runHook postInstall
    '';

    npmConfigHook = importNpmLock.npmConfigHook;
  }
