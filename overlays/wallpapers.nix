{
  den.overlays.wallpapers =
    { prev }:
    let
      inherit (prev) runCommandLocal;
    in
    {
      wallpapers =
        runCommandLocal "wallpapers" { } # bash
          ''
            mkdir -p $out

            cp ${./../assets/wallpaper/01.png} $out/01.png
          '';
    };
}
