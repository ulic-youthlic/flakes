{
  srcs,
  runCommandLocal,
  rootPath,
  lib,
}: let
  wallpapers = with lib;
    pipe srcs [
      (filterAttrs (name: _value: hasPrefix "wallpaper" name))
      (concatMapAttrsStringSep "\n" (name: value: "cp ${value.src} $out/${name}"))
    ];
in
  runCommandLocal "wallpapers" {} ''
    mkdir -p $out

    ${wallpapers}

    cp ${rootPath + "/assets/wallpaper/01.png"} $out/01.png
  ''
