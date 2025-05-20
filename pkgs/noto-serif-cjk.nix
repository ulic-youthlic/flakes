{
  nixosTests,
  srcs,
  stdenvNoCC,
}: let
  source = srcs.noto-serif-cjk;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "noto-serif-cjk";
    version = source.version;

    src = source.src;

    installPhase = ''
      install -m444 -Dt $out/share/fonts/opentype/noto-serif-cjk Serif/OTC/*.ttc
    '';

    passthru.tests.noto-fonts = nixosTests.noto-fonts;
  })
