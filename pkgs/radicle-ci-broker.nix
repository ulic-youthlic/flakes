{
  rustPlatform,
  srcs,
  git,
}: let
  inherit (srcs) radicle-ci-broker;
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "radicle-ci-broker";
    version = "0-unstable-${radicle-ci-broker.date}-git${radicle-ci-broker.version}";
    inherit (radicle-ci-broker) src;
    nativeBuildInputs = [git];

    cargoLock = {
      lockFile = "${finalAttrs.src}/Cargo.lock";
      allowBuiltinFetchGit = true;
    };

    doCheck = false;
  })
