{
  lib,
  stdenvNoCC,
  nodejs_24,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  src,
  date,
  rev,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "readest-web";
  version = "0.12.10-unstable.${date}-git${builtins.substring 0 7 rev}";
  inherit src;

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-E6z6mXT4fO5TueLiJ03xHTM0CN3u+zXiSfdioi8R85Q=";
  };

  env = {
    NEXT_TELEMETRY_DISABLED = "1";
    BUILD_STANDALONE = "true";
    NODE_OPTIONS = "--max-old-space-size=8192";
  };

  buildPhase = ''
    runHook preBuild

    pnpm --filter @readest/readest-app setup-vendors
    pnpm --filter @readest/readest-app build-web --webpack

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r apps/readest-app/.next/standalone/. $out/
    mkdir -p $out/apps/readest-app/.next/static $out/apps/readest-app/public
    cp -r apps/readest-app/.next/static/. $out/apps/readest-app/.next/static/
    cp -r apps/readest-app/public/. $out/apps/readest-app/public/

    runHook postInstall
  '';

  meta = {
    description = "Readest standalone web app from the AndyScarlet233 fork";
    homepage = "https://github.com/AndyScarlet233/readest";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
  };
})
