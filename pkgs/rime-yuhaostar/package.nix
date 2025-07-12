{
  srcs,
  stdenv,
  unzip,
}:
let
  inherit (srcs.rime-yuhaostar) src version;
in
stdenv.mkDerivation {
  pname = "rime-yuhaostar";
  version =
    if version != "v3.9.0" then
      throw ''
        Please update 宇浩输入法。
      ''
    else
      version;
  inherit src;
  nativeBuildInputs = [ unzip ];

  sourceRoot = "schema";

  patches = [
    ./punctuator.patch
    ./key_binder.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp -rt $out/share/rime-data -- ./*
    rm $out/share/rime-data/default.custom.yaml

    runHook postInstall
  '';
}
