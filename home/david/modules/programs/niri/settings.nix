{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  inherit (lib) getExe getExe';
  DISPLAY = ":1";
  bash = getExe pkgs.bash;
  swaylock = getExe pkgs.swaylock-effects;
  fuzzel = getExe pkgs.fuzzel;
  wpctl = getExe' pkgs.wireplumber "wpctl";
  waybar = getExe pkgs.waybar;
  swaync = getExe pkgs.swaynotificationcenter;
  swaybg = getExe pkgs.swaybg;
  fcitx5 = getExe' osConfig.i18n.inputMethod.package "fcitx5";
  xwayland-satellite = getExe pkgs.xwayland-satellite;
  polkit-kde-agent = getExe' pkgs.kdePackages.polkit-kde-agent-1 "polkit-kde-agent";
  wl-paste = getExe' pkgs.wl-clipboard "wl-paste";
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
  cliphist = getExe' pkgs.cliphist "cliphist";
  ghostty = getExe pkgs.ghostty;
in {
  binds = let
    inherit (config.lib.niri.actions) spawn show-hotkey-overlay toggle-column-tabbed-display close-window toggle-overview focus-column-left focus-window-down focus-window-up focus-column-right focus-column-or-monitor-left focus-window-or-workspace-down focus-window-or-workspace-up focus-column-or-monitor-right move-column-left move-window-down move-window-up move-column-right move-column-left-or-to-monitor-left move-window-down-or-to-workspace-down move-window-up-or-to-workspace-up move-column-right-or-to-monitor-right focus-column-first focus-column-last move-column-to-first move-column-to-last focus-monitor-left focus-monitor-down focus-monitor-up focus-monitor-right move-column-to-monitor-left move-column-to-monitor-down move-column-to-monitor-up move-column-to-monitor-right focus-workspace-up focus-workspace-down move-column-to-workspace-down move-column-to-workspace-up move-workspace-down move-workspace-up focus-workspace move-column-to-workspace toggle-window-floating toggle-windowed-fullscreen focus-window-previous switch-focus-between-floating-and-tiling consume-or-expel-window-left consume-or-expel-window-right consume-window-into-column expel-window-from-column switch-preset-column-width switch-preset-window-height reset-window-height maximize-column fullscreen-window center-column set-column-width set-window-height screenshot screenshot-window quit expand-column-to-available-width toggle-keyboard-shortcuts-inhibit set-dynamic-cast-window clear-dynamic-cast-target;
  in {
    "Mod+V".action = spawn bash "-c" "${cliphist} list | ${fuzzel} --dmenu | ${cliphist} decode | ${wl-copy}";
    "Mod+Shift+P".action = spawn swaylock "--screenshots" "--clock" "--indicator" "--indicator-radius" "100" "--indicator-thickness" "7" "--effect-blur" "7x5" "--effect-vignette" "0.5:0.5" "--grace" "2" "--fade-in" "0.5";
    "Mod+Shift+Slash".action = show-hotkey-overlay;
    "Mod+T".action = spawn ghostty;
    "Mod+Shift+T".action = toggle-column-tabbed-display;
    "Mod+Space".action = spawn fuzzel;
    XF86AudioRaiseVolume = {
      action = spawn wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
      allow-when-locked = true;
    };
    XF86AudioLowerVolume = {
      action = spawn wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
      allow-when-locked = true;
    };
    XF86AudioMute = {
      action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      allow-when-locked = true;
    };
    XF86AudioMicMute = {
      action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
      allow-when-locked = true;
    };
    "Mod+Q".action = close-window;
    "Mod+O".action = toggle-overview;
    "Mod+Left".action = focus-column-left;
    "Mod+Down".action = focus-window-down;
    "Mod+Up".action = focus-window-up;
    "Mod+Right".action = focus-column-right;
    "Mod+H".action = focus-column-or-monitor-left;
    "Mod+J".action = focus-window-or-workspace-down;
    "Mod+K".action = focus-window-or-workspace-up;
    "Mod+L".action = focus-column-or-monitor-right;
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Down".action = move-window-down;
    "Mod+Shift+Up".action = move-window-up;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+H".action = move-column-left-or-to-monitor-left;
    "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
    "Mod+Shift+K".action = move-window-up-or-to-workspace-up;
    "Mod+Shift+L".action = move-column-right-or-to-monitor-right;
    "Mod+Home".action = focus-column-first;
    "Mod+End".action = focus-column-last;
    "Mod+Ctrl+Home".action = move-column-to-first;
    "Mod+Ctrl+End".action = move-column-to-last;
    "Mod+Ctrl+Left".action = focus-monitor-left;
    "Mod+Ctrl+Down".action = focus-monitor-down;
    "Mod+Ctrl+Up".action = focus-monitor-up;
    "Mod+Ctrl+Right".action = focus-monitor-right;
    "Mod+Ctrl+H".action = focus-monitor-left;
    "Mod+Ctrl+J".action = focus-monitor-down;
    "Mod+Ctrl+K".action = focus-monitor-up;
    "Mod+Ctrl+L".action = focus-monitor-right;
    "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
    "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
    "Mod+Page_Down".action = focus-workspace-down;
    "Mod+Page_Up".action = focus-workspace-up;
    "Mod+U".action = focus-workspace-down;
    "Mod+I".action = focus-workspace-up;
    "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
    "Mod+Shift+Page_Up".action = move-column-to-workspace-up;
    "Mod+Shift+U".action = move-column-to-workspace-down;
    "Mod+Shift+I".action = move-column-to-workspace-up;
    "Mod+Ctrl+Page_Down".action = move-workspace-down;
    "Mod+Ctrl+Page_Up".action = move-workspace-up;
    "Mod+Ctrl+U".action = move-workspace-down;
    "Mod+Ctrl+I".action = move-workspace-up;
    "Mod+Shift+WheelScrollDown" = {
      action = focus-workspace-down;
      cooldown-ms = 150;
    };
    "Mod+Shift+WheelScrollUp" = {
      action = focus-workspace-up;
      cooldown-ms = 150;
    };
    "Mod+WheelScrollDown".action = focus-column-right;
    "Mod+WheelScrollUp".action = focus-column-left;
    "Mod+1".action = focus-workspace 1;
    "Mod+2".action = focus-workspace 2;
    "Mod+3".action = focus-workspace 3;
    "Mod+4".action = focus-workspace 4;
    "Mod+5".action = focus-workspace 5;
    "Mod+6".action = focus-workspace 6;
    "Mod+7".action = focus-workspace 7;
    "Mod+8".action = focus-workspace 8;
    "Mod+9".action = focus-workspace 9;
    "Mod+Shift+1".action = move-column-to-workspace 1;
    "Mod+Shift+2".action = move-column-to-workspace 2;
    "Mod+Shift+3".action = move-column-to-workspace 3;
    "Mod+Shift+4".action = move-column-to-workspace 4;
    "Mod+Shift+5".action = move-column-to-workspace 5;
    "Mod+Shift+6".action = move-column-to-workspace 6;
    "Mod+Shift+7".action = move-column-to-workspace 7;
    "Mod+Shift+8".action = move-column-to-workspace 8;
    "Mod+Shift+9".action = move-column-to-workspace 9;
    "Mod+F".action = toggle-window-floating;
    "Mod+Shift+F".action = toggle-windowed-fullscreen;
    "Mod+Tab".action = focus-window-previous;
    "Mod+Shift+Tab".action = switch-focus-between-floating-and-tiling;
    "Mod+BracketLeft".action = consume-or-expel-window-left;
    "Mod+BracketRight".action = consume-or-expel-window-right;
    "Mod+Comma".action = consume-window-into-column;
    "Mod+Period".action = expel-window-from-column;
    "Mod+R".action = switch-preset-column-width;
    "Mod+Shift+R".action = switch-preset-window-height;
    "Mod+Ctrl+R".action = reset-window-height;
    "Mod+M".action = maximize-column;
    "Mod+Shift+M".action = fullscreen-window;
    "Mod+Z".action = center-column;
    "Mod+Minus".action = set-column-width "-10%";
    "Mod+Equal".action = set-column-width "+10%";
    "Mod+Shift+Minus".action = set-window-height "-10%";
    "Mod+Shift+Equal".action = set-window-height "+10%";
    "Print".action = screenshot;
    # since niri add another parameter for the variant, the regex can not parse the action
    # [Track] https://github.com/sodiboo/niri-flake/issues/922
    "Ctrl+Print".action.screenshot-screen = [];
    "Alt+Print".action = screenshot-window;
    "Mod+Shift+Q".action = quit;
    "Mod+E".action = expand-column-to-available-width;
    "Mod+Shift+S".action = toggle-keyboard-shortcuts-inhibit;
    "Mod+Shift+C".action = set-dynamic-cast-window;
    "Mod+Shift+Ctrl+C".action = clear-dynamic-cast-target;
  };
  screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d_%H:%M:%S.png";
  hotkey-overlay.skip-at-startup = true;
  prefer-no-csd = true;
  spawn-at-startup = [
    {
      command = [waybar];
    }
    {
      command = [swaync];
    }
    {
      command = [swaybg "-i" "${config.home.homeDirectory}/wallpaper/01.png"];
    }
    {
      command = [fcitx5 "-d" "--replace"];
    }
    {
      command = [xwayland-satellite DISPLAY];
    }
    {
      command = [polkit-kde-agent];
    }
    {
      command = [wl-paste "--watch" cliphist "store"];
    }
  ];
  input = {
    touchpad = {
      click-method = "clickfinger";
      dwt = true;
      scroll-method = "two-finger";
      tap-button-map = "left-right-middle";
    };
    warp-mouse-to-focus = true;
  };
  cursor = {
    hide-after-inactive-ms = 3000;
    hide-when-typing = true;
  };
  layout = {
    border = {
      enable = true;
      width = 4;
      active = {
        color = "#7fc8ff";
      };
      inactive = {
        color = "#505050";
      };
    };
    focus-ring = {
      enable = false;
      width = 4;
      active = {
        color = "#7fc8ff";
      };
      inactive = {
        color = "#505050";
      };
    };
    preset-column-widths = [
      {
        proportion = 1. / 4.;
      }
      {
        proportion = 1. / 3.;
      }
      {
        proportion = 1. / 2.;
      }
      {
        proportion = 2. / 3.;
      }
      {
        proportion = 3. / 4.;
      }
      {
        proportion = 4. / 4.;
      }
    ];
    always-center-single-column = true;
    center-focused-column = "never";
    default-column-display = "tabbed";
    default-column-width = {
      proportion = 1. / 2.;
    };
    empty-workspace-above-first = true;
    gaps = 16;
  };
  animations = {
    enable = true;
    window-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
  };
  environment = {
    inherit DISPLAY;
  };
  window-rules = [
    {
      draw-border-with-background = true;
      geometry-corner-radius = {
        bottom-left = 12.;
        bottom-right = 12.;
        top-left = 12.;
        top-right = 12.;
      };
      clip-to-geometry = true;
    }
    {
      matches = [
        {
          app-id = "^showmethekey-gtk$";
        }
      ];
      geometry-corner-radius = {
        bottom-left = 0.0;
        bottom-right = 0.0;
        top-left = 0.0;
        top-right = 0.0;
      };
      clip-to-geometry = false;
      open-floating = true;
      open-focused = false;
      default-column-width = {
        fixed = 300;
      };
      default-window-height = {
        fixed = 70;
      };
      draw-border-with-background = false;
      default-floating-position = {
        relative-to = "bottom-right";
        x = 20;
        y = 20;
      };
      focus-ring.enable = false;
      border.enable = false;
      shadow.enable = false;
      baba-is-float = true;
      # tiled-state = false;
    }
    {
      matches = [
        {
          app-id = "^org\\.keepassxc\\.KeePassXC$";
        }
        {
          app-id = "^org\\.gnome\\.World\\.Secrets$";
        }
      ];
      block-out-from = "screen-capture";
    }
    {
      matches = [
        {
          app-id = "^com\\.mitchellh\\.ghostty$";
          is-active = true;
        }
      ];
      draw-border-with-background = false;
    }
    {
      matches = [
        {
          app-id = "^com\\.mitchellh\\.ghostty$";
          is-active = false;
        }
      ];
      opacity = 0.8;
      draw-border-with-background = false;
    }
    {
      matches = [
        {
          is-window-cast-target = true;
        }
      ];
      focus-ring = {
        active = {
          color = "#f38ba8";
        };
        inactive = {
          color = "#7d0d2d";
        };
      };
      border = {
        active = {
          color = "#f38ba8";
        };
        inactive = {
          color = "#7d0d2d";
        };
      };
      tab-indicator = {
        active = {
          color = "#f38ba8";
        };
        inactive = {
          color = "#7d0d2d";
        };
      };
      shadow.enable = true;
    }
    {
      matches = [
        {
          app-id = "^org\\.telegram\\.desktop$";
          title = "Media viewer";
        }
      ];
      open-floating = true;
    }
  ];
  layer-rules = [
    {
      matches = [
        {
          namespace = "^swaync-notification-window$";
        }
        {
          namespace = "^swaync-control-center$";
        }
      ];
      block-out-from = "screen-capture";
    }
    {
      matches = [
        {
          namespace = "^launcher$";
        }
      ];
      shadow.enable = true;
      geometry-corner-radius = {
        top-left = 10.;
        top-right = 10.;
        bottom-left = 10.;
        bottom-right = 10.;
      };
    }
  ];
}
