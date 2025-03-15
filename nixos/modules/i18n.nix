{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.youthlic.i18n;
in
{
  options = {
    youthlic.i18n = {
      enable = lib.mkEnableOption "zh env";
    };
  };
  config = lib.mkIf cfg.enable {
    i18n = {
      defaultLocale = "C.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "zh_CN.UTF-8";
        LC_IDENTIFICATION = "zh_CN.UTF-8";
        LC_MEASUREMENT = "zh_CN.UTF-8";
        LC_MONETARY = "zh_CN.UTF-8";
        LC_NAME = "zh_CN.UTF-8";
        LC_NUMERIC = "zh_CN.UTF-8";
        LC_PAPER = "zh_CN.UTF-8";
        LC_TELEPHONE = "zh_CN.UTF-8";
        LC_TIME = "zh_CN.UTF-8";
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = with pkgs; [
            libsForQt5.fcitx5-qt
            fcitx5-gtk
            fcitx5-fluent
            (fcitx5-rime.override {
              rimeDataPkgs = [
                rime-ice
              ];
            })
          ];
          waylandFrontend = true;
          # rime deploy need use user config dir
          # ignoreUserConfig = false;
          settings = {
            addons = {
              classicui.globalSection.Theme = "FluentDark-solid";
            };
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "keyboard-us";
              };
              "Groups/0/Items/0" = {
                Name = "keyboard-us";
                Layout = "";
              };
              "Groups/0/Items/1" = {
                Name = "rime";
                Layout = "";
              };
            };
          };
        };
      };
    };
  };
}
