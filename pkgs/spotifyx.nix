{
  pkgs,
  srcs,
}: let
  inherit (srcs) spotx;
in
  pkgs.spotify.overrideAttrs (final: prev: {
    version = prev.version + "_spotx-${spotx.version}";
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
  })
