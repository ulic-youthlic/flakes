{
  srcs,
  stdenv,
  unzip,
}: let
  inherit (srcs.rime-yuhaostar) src version;
in
  stdenv.mkDerivation {
    pname = "rime-yuhaostar";
    version = version;
    inherit src;
    nativeBuildInputs = [unzip];

    sourceRoot = "schema";

    patches = [./punctuator.patch ./key_binder.patch];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/rime-data
      cp -rt $out/share/rime-data -- ./*
      rm $out/share/rime-data/default.custom.yaml

      runHook postInstall
    '';
  }
