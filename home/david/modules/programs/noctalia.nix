{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.david.programs.noctalia;
  inherit (inputs.niri-flake.lib.kdl) node leaf flag plain;
  spawn = leaf "spawn";
  noctalia = args: (spawn (["noctalia-shell" "ipc" "call"] ++ args));

  layer-rule = plain "layer-rule";
  match = leaf "match";
in {
  options = {
    david.programs.noctalia = {
      enable = lib.mkEnableOption "noctalia";
      niriExtraConfig = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
        default = [
          (plain "binds" [
            (plain "Mod+V" [(noctalia ["launcher" "clipboard"])])
            (plain "Mod+Shift+P" [(noctalia ["lockScreen" "lock"])])
            (plain "Mod+Space" [(noctalia ["launcher" "toggle"])])
            (node "XF86AudioRaiseVolume" [{allow-when-locked = true;}]
              [(noctalia ["volume" "increase"])])
            (node "XF86AudioLowerVolume" [{allow-when-locked = true;}]
              [(noctalia ["volume" "decrease"])])
            (node "XF86AudioMute" [{allow-when-locked = true;}]
              [(noctalia ["volume" "muteOutput"])])
            (node "XF86AudioMicMute" [{allow-when-locked = true;}]
              [(noctalia ["volume" "muteInput"])])
          ])
          (layer-rule [
            (match [{namespace = "^noctalia-wallpaper-.*$";}])
            (leaf "place-within-backdrop" [true])
          ])
          (layer-rule [
            (match [{namespace = "^noctalia-notifications-.*$";}])
            (leaf "block-out-from" ["screen-capture"])
          ])
          (plain "layout" [
            (plain "focus-ring" [
              (leaf "active-gradient" [
                {
                  from = "#8288fcff";
                  to = "#8288fc00";
                  angle = 45;
                  "in" = "oklch";
                }
              ])
            ])
          ])
        ];
        apply = configuration: config.david.programs.niri.configHelper.validated-config-for (inputs.niri-flake.lib.kdl.serialize.nodes configuration);
      };
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.noctalia-shell.enable = false;
    home.packages = [pkgs.app2unit];
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        settingsVersion = 23;
        appLauncher = {
          enableClipboardHistory = true;
          position = "center";
          sortByMostUsed = true;
          terminalCommand = "ghostty -e";
          useApp2Unit = true;
        };
        audio = {
          volumeStep = 1;
          volumeOverdrive = true;
          cavaFrameRate = 165;
          visualizerQuality = "high";
          visualizerType = "mirrored";
        };
        bar = {
          density = "comfortable";
          exclusive = true;
          floating = false;
          outerCorners = true;
          position = "right";
          showCapsule = true;
          widgets = {
            center = [
              {id = "Taskbar";}
              {
                id = "Workspace";
                hideUnoccupied = true;
              }
            ];
            left = [
              {id = "SystemMonitor";}
              {
                id = "MediaMini";
                hideWhenIdle = false;
                hideMode = "hidden";
                showAlbumArt = true;
              }
              {
                id = "AudioVisualizer";
                hideWhenIdle = true;
              }
            ];
            right = [
              {id = "WallpaperSelector";}
              {id = "ScreenRecorder";}
              {id = "Brightness";}
              {id = "DarkMode";}
              {id = "NotificationHistory";}
              {id = "Volume";}
              {
                id = "Tray";
                drawerEnabled = true;
                pinned = [
                  "Fcitx"
                ];
              }
              {id = "Clock";}
            ];
          };
        };
        brightness = {
          brightnessStep = 1;
          enableDdcSupport = true;
          enforceMinimum = true;
        };
        colorSchemes = {
          generateTemplatesForPredefined = false;
          predefinedScheme = "Catppuccin";
          schedulingMode = "location";
          useWallpaperColors = false;
          darkMode = false;
        };
        controlCenter = {
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
          position = "close_to_bar_button";
          shortcuts = {
            left = [{id = "Bluetooth";} {id = "WallpaperSelector";}];
            right = [{id = "KeepAwake";} {id = "NightLight";}];
          };
        };
        dock = {
          enabled = false;
        };
        general = {
          animationSpeed = 2;
          avatarImage = "${config.home.homeDirectory}/.face";
          compactLockScreen = false;
          dimmerOpacity = 0;
          enableShadows = true;
          forceBlackScreenCorners = false;
          language = "zh-CN";
          lockOnSuspend = true;
          showScreenCorners = false;
        };
        location = {
          firstDayOfWeek = 1;
          showCalendarEvents = true;
          showCalendarWeather = true;
          weatherEnabled = true;
        };
        network = {
          wifiEnabled = false;
        };
        notifications = {
          enabled = true;
          location = "bottom_right";
          overlayLayer = true;
          respectExpireTimeout = true;
        };
        osd = {
          enabled = true;
          location = "bottom";
          overlayLayer = true;
        };
        setupCompleted = true;
        ui = {
          fontDefault = "Source Han Serif SC";
          fontFixed = "Maple Mono NF CN";
          panelsAttachedToBar = true;
          settingsPanelAttachToBar = false;
          tooltipsEnabled = true;
        };
        wallpaper = {
          directory = "${config.home.homeDirectory}/wallpaper";
          enabled = true;
          panelPosition = "center";
          randomEnabled = true;
          randomIntervalSec = 900;
          recursiveSearch = true;
          transitionDuration = 1500;
          transitionType = "random";
        };
      };
    };
  };
}
