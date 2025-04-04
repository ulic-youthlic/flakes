{
  nixosTests,
  srcs,
  stdenvNoCC,
  ...
}:
let
  source = srcs.noto-sans-cjk;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "noto-sans-cjk";
  version = source.version;

  src = source.src;

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-sans-cjk Sans/OTC/*.ttc
  '';

  passthru.tests.noto-fonts = nixosTests.noto-fonts;
})
