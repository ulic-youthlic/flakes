{
  srcs,
  cliphist,
  imagemagick,
  wl-clipboard,
  fuzzel,
  gawk,
  gnugrep,
  lib,
  makeWrapper,
}: let
  inherit (srcs.cliphist) src date version;
in
  cliphist.overrideAttrs (final: prev: {
    inherit src;
    version =
      if prev.version != "0.6.1"
      then
        throw ''
          Please remove <pkgs/cliphist.nix>
        ''
      else "0-unstable-${date}-git${version}";
    vendorHash = "sha256-No8d9ztepBO+fgF2XkEf/tyCPDAD57rBkzA8iVyNUmw=";
    buildInputs =
      (prev.buildInputs or [])
      ++ [
        makeWrapper
      ];
    postInstall = ''
      cp -t $out/bin/ $src/contrib/*
      rm $out/bin/cliphist.service
      wrapProgram $out/bin/cliphist-fuzzel-img \
      --prefix PATH : ${lib.makeBinPath [
        imagemagick
        wl-clipboard
        fuzzel
        gawk
        gnugrep
      ]}
    '';
  })
