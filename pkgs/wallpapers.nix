{
  srcs,
  runCommandLocal,
  rootPath,
  lib,
}:
let
  wallpapers =
    with lib;
    pipe srcs [
      (filterAttrs (name: _value: hasPrefix "wallpaper" name))
      (concatMapAttrsStringSep "\n" (name: value: "ln -s ${value.src} $out/${name}"))
    ];
in
runCommandLocal "wallpapers" { } ''
  mkdir -p $out

  ${wallpapers}

  ln -s ${rootPath + "/assets/wallpaper/01.png"} $out/01.png
''
