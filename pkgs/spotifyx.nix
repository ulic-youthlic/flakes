{
  spotify,
  unzip,
  zip,
  perl,
  symlinkJoin,
  srcs,
}: let
  inherit (srcs) spotx;
  spotifyx = spotify.overrideAttrs (_final: prev: {
    nativeBuildInputs =
      prev.nativeBuildInputs
      ++ [
        unzip
        zip
        perl
      ];
    spotx = spotx.src;
    postUnpack = ''
      cp $spotx/spotx.sh ./spotx.sh
      chmod +x ./spotx.sh
      patchShebangs --build ./spotx.sh
    '';
    postInstall = ''
      ./spotx.sh -P $out/share/spotify -h
    '';
  });
in
  symlinkJoin {
    name = "spotifyx";
    paths = [spotifyx];
  }
