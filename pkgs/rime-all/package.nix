{
  rime-ice,
  rime-yuhaostar,
  rime-moegirl,
  rime-zhwiki,
  buildEnv,
  librime,
  rime-data,
}:
buildEnv {
  name = "rime-all";
  paths = [
    rime-ice
    rime-yuhaostar
    rime-zhwiki
    rime-moegirl
  ];
  nativeBuildInputs = [
    librime
  ];
  postBuild = ''
    ln -s ${./yustar_sc.custom.yaml} $out/share/rime-data/yustar_sc.custom.yaml
    ln -s ${./double_pinyin_flypy.custom.yaml} $out/share/rime-data/double_pinyin_flypy.custom.yaml
    ln -s ${./default.custom.yaml} $out/share/rime-data/default.custom.yaml

    cd $out/share/rime-data/
    for s in *.schema.yaml; do
      rime_deployer --compile "$s" . "${rime-data}/share/rime-data/" ./build
    done

    rm ./build/*.txt
  '';
}
