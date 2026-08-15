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
      extraLocales = [ "zh_CN.UTF-8/UTF-8" ];
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
                rime-all
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
                "Vertical Candidate List" = "True";
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
                EnumerateWithTriggerKeys = "True";
                EnumerateSkipFirst = "False";
                ModifierOnlyKeyTimeout = 250;
              };
              "Hotkey/TogglePreedit" = {
                "0" = "Control+Shift+P";
              };
              "Hotkey/NextCandidate" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/PrevCandidate" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/NextPage" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/PrevPage" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/ActivateKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/EnumerateGroupBackwardKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/EnumerateGroupForwardKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/EnumerateBackwardKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/EnumerateForwardKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/AltTriggerKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/DeactivateKeys" = {
                "0" = "VoidSymbol";
              };
              "Hotkey/TriggerKeys" = {
                "0" = "Shift+space";
              };
              Behavior = {
                ActiveByDefault = "False";
                AllowInputMethodForPassword = "False";
                AutoSavePeriod = 30;
                CompactInputMethodInformation = "True";
                CustomXkbOption = "";
                DefaultPageSize = 7;
                DisabledAddons = "";
                EnabledAddons = "";
                OverrideXkbOption = "False";
                PreeditEnabledByDefault = "True";
                PreloadInputMethod = "True";
                ShareInputState = "No";
                ShowFirstInputMethodInformation = "True";
                ShowInputMethodInformation = "False";
                ShowPreeditForPassword = "False";
                resetStateWhenFocusIn = "No";
                showInputMethodInformationWhenFocusIn = "False";
              };
            };
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "rime";
              };
              "Groups/0/Items/0" = {
                Name = "keyboard-us";
                Layout = "";
              };
              "Groups/0/Items/1" = {
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
