{
  srcs,
  runCommandNoCCLocal,
  rootPath,
}:
runCommandNoCCLocal "wallpapers" {} ''
  mkdir -p $out

  ln -s ${srcs."wallpaper_hieda-no-akyuu-touhou.1920x1080.mp4".src} $out/wallpaper_hieda-no-akyuu-touhou.1920x1080.mp4
  ln -s ${srcs."wallpaper_outer-wilds.3840x2160.mp4".src} $out/wallpaper_outer-wilds.3840x2160.mp4
  ln -s ${rootPath + "/assets/wallpaper/01.png"} $out/01.png
''
