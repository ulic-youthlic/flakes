{
  spotify,
  unzip,
  zip,
  perl,
  makeWrapper,
  srcs,
}:
let
  inherit (srcs) spotx;
in
spotify.overrideAttrs (
  _final: prev: {
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      unzip
      zip
      perl
      makeWrapper
    ];
    spotx = spotx.src;
    postUnpack = ''
      cp $spotx/spotx.sh ./spotx.sh
      chmod +x ./spotx.sh
      patchShebangs --build ./spotx.sh
    '';
    postInstall = ''
      ./spotx.sh -P $out/share/spotify -h -p
    '';
    postFixup = ''
      wrapProgram $out/bin/spotify \
        --set NIXOS_OZONE_WL 1 \
        --add-flags '--wayland-text-input-version=3'
    '';
  }
)
