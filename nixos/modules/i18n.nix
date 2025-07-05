{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.i18n;
in {
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
                rime-zhwiki
                rime-moegirl
                rime-yuhaostar
              ];
            })
          ];
          waylandFrontend = true;
          # rime deploy need use user config dir
          # ignoreUserConfig = false;
          settings = {
            addons = {
              classicui.globalSection = {
                Theme = "FluentDark-solid";
                "Vertical Candidate List" = true;
              };
              notifications.globalSection = {
                HiddenNotifications = "";
              };
              clipboard.globalSection = {
                TriggerKey = "";
                PastePrimaryKey = "";
              };
            };
            globalOptions = {
              HotKey = {
                ActivateKeys = "";
                AltTriggerKeys = "";
                DeactivateKeys = "";
                EnumerateBackwardKeys = "";
                EnumerateForwardKeys = "";
                EnumerateGroupBackwardKeys = "";
                EnumerateGroupForwardKeys = "";
                EnumerateSkipFirst = false;
                EnumerateWithTriggerKeys = true;
                ModifierOnlyKeyTimeout = "250";
                NextCandidate = "";
                NextPage = "";
                PrevCandidate = "";
                PrevPage = "";
                TogglePreedit = "";
                TriggerKeys = "";
              };
              Behavior = {
                ActiveByDefault = false;
                AllowInputMethodForPassword = false;
                AutoSavePeriod = 30;
                CompactInputMethodInformation = true;
                CustomXkbOption = "";
                DefaultPageSize = 7;
                DisabledAddons = "";
                EnabledAddons = "";
                OverrideXkbOption = false;
                PreeditEnabledByDefault = true;
                PreloadInputMethod = true;
                ShareInputState = "No";
                ShowFirstInputMethodInformation = true;
                ShowInputMethodInformation = true;
                ShowPreeditForPassword = false;
                resetStateWhenFocusIn = "No";
                showInputMethodInformationWhenFocusIn = false;
              };
            };
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "keyboard-us";
              };
              "Groups/0/Items/0" = {
                Name = "rime";
                Layout = "";
              };
              "GroupOrder" = {
                "0" = "Default";
              };
            };
          };
        };
      };
    };
  };
}
