{
  rime-ice,
  rime-yuhaostar,
  rime-moegirl,
  rime-zhwiki,
  buildEnv,
}:
buildEnv {
  name = "rime-all";
  paths = [
    rime-ice
    rime-yuhaostar
    rime-zhwiki
    rime-moegirl
  ];
  postBuild = ''
    ln -s ${./yustar_sc.custom.yaml} $out/share/rime-data/yustar_sc.custom.yaml
    ln -s ${./double_pinyin_flypy.custom.yaml} $out/share/rime-data/double_pinyin_flypy.custom.yaml
    ln -s ${./default.custom.yaml} $out/share/rime-data/default.custom.yaml
  '';
}
