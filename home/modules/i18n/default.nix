{
  osConfig ? null,
  lib,
  ...
}:
{
  config = lib.mkIf (osConfig != null) {
    xdg.dataFile = {
      "fcitx5/rime/default.custom.yaml".source = ./default.custom.yaml;
      "fcitx5/rime/double_pinyin_flypy.custom.yaml".source = ./double_pinyin_flypy.custom.yaml;
      "fcitx5/rime/yustar_sc.custom.yaml".source = ./yustar_sc.custom.yaml;
    };
  };
}
