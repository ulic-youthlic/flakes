{
  runCommandLocal,
  rootPath,
}:
runCommandLocal "wallpapers" {} ''
  mkdir -p $out

  cp ${rootPath + "/assets/wallpaper/01.png"} $out/01.png
''
