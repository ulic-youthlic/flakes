{
  srcs,
  stdenvNoCC,
  ...
}: let
  source = srcs.rime-ice;
in
  stdenvNoCC.mkDerivation {
    inherit (source) pname version src;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/rime-data
      cp -r * $out/share/rime-data/

      runHook postInstall
    '';
  }
