{
  pkgs,
  srcs,
}: let
  inherit (srcs) spotx;
  spotifyx = pkgs.spotify.overrideAttrs (final: prev: {
    nativeBuildInputs =
      prev.nativeBuildInputs
      ++ (with pkgs; [
        unzip
        zip
        perl
      ]);
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
  pkgs.symlinkJoin {
    name = "spotifyx";
    paths = [spotifyx];
  }
