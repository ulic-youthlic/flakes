{
  config,
  pkgs,
  lib,
  inputs,
  DISPLAY,
  ...
}: let
  inherit (lib) getExe getExe';
  inherit
    (inputs.niri-flake.lib.kdl)
    # node with args, props and children
    # node:: \lambda name -> [argOrProp] -> [child] -> Output
    # arg: single value
    # prop: attr contains one or more key-value pair
    # children: node
    node
    # node without children
    # leaf:: \lambda name -> [argOrProp] -> Output
    leaf
    # node only name
    # flag:: \lambda name -> Output
    flag
    # node without args/props
    # plain:: \lambda name -> [child] -> Output
    plain
    ;

  bash = getExe config.programs.bash.package;
  swaylock = getExe config.programs.swaylock.package;
  fuzzel = getExe config.programs.fuzzel.package;
  waybar = getExe config.programs.waybar.package;
  swaync = getExe config.services.swaync.package;

  polkit-kde-agent = getExe' pkgs.kdePackages.polkit-kde-agent-1 "polkit-kde-agent";
  wpctl = getExe' pkgs.wireplumber "wpctl";
  swaybg = getExe pkgs.swaybg;
  ghostty = getExe config.programs.ghostty.package;
  wl-paste = getExe' pkgs.wl-clipboard "wl-paste";
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
  cliphist = getExe' pkgs.cliphist "cliphist";
in
  (
    let
      spawn = leaf "spawn";
    in [
      (plain "binds" [
        (plain "Mod+V" [
          (spawn [bash "-c" "${cliphist} list | ${fuzzel} --dmenu | ${cliphist} decode | ${wl-copy}"])
        ])
        (plain "Mod+Shift+P" [
          (spawn [swaylock "--screenshots" "--clock" "--indicator" "--indicator-radius" "100" "--indicator-thickness" "7" "--effect-blur" "7x5" "--effect-vignette" "0.5:0.5" "--grace" "2" "--fade-in" "0.5"])
        ])
        (plain "Mod+Shift+Slash" [
          (flag "show-hotkey-overlay")
        ])
        (plain "Mod+T" [
          (spawn [
            ghostty
          ])
        ])
        (plain "Mod+Shift+T" [
          (flag "toggle-column-tabbed-display")
        ])
        (plain "Mod+Space" [
          (spawn fuzzel)
        ])
        (node "XF86AudioRaiseVolume" {allow-when-locked = true;} [
          (spawn [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"])
        ])
        (node "XF86AudioLowerVolume" {allow-when-locked = true;} [
          (spawn [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"])
        ])
        (node "XF86AudioMute" {allow-when-locked = true;} [
          (spawn [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "toggle"])
        ])
        (node "XF86AudioMicMute" {allow-when-locked = true;} [
          (spawn [wpctl "set-volume" "@DEFAULT_AUDIO_SOURCE@" "toggle"])
        ])
        (plain "Mod+Q" [
          (flag "close-window")
        ])
        (node "Mod+O" {repeat = false;} [
          (flag "toggle-overview")
        ])
        (plain "Mod+Left" [
          (flag "focus-column-left")
        ])
        (plain "Mod+Down" [
          (flag "focus-window-down")
        ])
        (plain "Mod+Up" [
          (flag "focus-window-up")
        ])
        (plain "Mod+Right" [
          (flag "focus-column-right")
        ])
        (plain "Mod+H" [
          (flag "focus-column-or-monitor-left")
        ])
        (plain "Mod+J" [
          (flag "focus-window-or-workspace-down")
        ])
        (plain "Mod+K" [
          (flag "focus-window-or-workspace-up")
        ])
        (plain "Mod+L" [
          (flag "focus-column-or-monitor-right")
        ])
        (plain "Mod+Shift+Left" [
          (flag "move-column-left")
        ])
        (plain "Mod+Shift+Down" [
          (flag "move-window-down")
        ])
        (plain "Mod+Shift+Up" [
          (flag "move-window-up")
        ])
        (plain "Mod+Shift+Right" [
          (flag "move-column-right")
        ])
        (plain "Mod+Shift+H" [
          (flag "move-column-left-or-to-monitor-left")
        ])
        (plain "Mod+Shift+J" [
          (flag "move-window-down-or-to-workspace-down")
        ])
        (plain "Mod+Shift+K" [
          (flag "move-window-up-or-to-workspace-up")
        ])
        (plain "Mod+Shift+L" [
          (flag "move-column-right-or-to-monitor-right")
        ])
        (plain "Mod+Home" [
          (flag "focus-column-first")
        ])
        (plain "Mod+End" [
          (flag "focus-column-last")
        ])
        (plain "Mod+Ctrl+Home" [
          (flag "move-column-to-first")
        ])
        (plain "Mod+Ctrl+End" [
          (flag "move-column-to-last")
        ])
        (plain "Mod+Ctrl+Left" [
          (flag "focus-monitor-left")
        ])
        (plain "Mod+Ctrl+Down" [
          (flag "focus-monitor-down")
        ])
        (plain "Mod+Ctrl+Up" [
          (flag "focus-monitor-up")
        ])
        (plain "Mod+Ctrl+Right" [
          (flag "focus-monitor-right")
        ])
        (plain "Mod+Ctrl+H" [
          (flag "focus-monitor-left")
        ])
        (plain "Mod+Ctrl+J" [
          (flag "focus-monitor-down")
        ])
        (plain "Mod+Ctrl+K" [
          (flag "focus-monitor-up")
        ])
        (plain "Mod+Ctrl+L" [
          (flag "focus-monitor-right")
        ])
        (plain "Mod+Shift+Ctrl+Left" [
          (flag "move-column-to-monitor-left")
        ])
        (plain "Mod+Shift+Ctrl+Down" [
          (flag "move-column-to-monitor-down")
        ])
        (plain "Mod+Shift+Ctrl+Up" [
          (flag "move-column-to-monitor-up")
        ])
        (plain "Mod+Shift+Ctrl+Right" [
          (flag "move-column-to-monitor-right")
        ])
        (plain "Mod+Shift+Ctrl+H" [
          (flag "move-column-to-monitor-left")
        ])
        (plain "Mod+Shift+Ctrl+J" [
          (flag "move-column-to-monitor-down")
        ])
        (plain "Mod+Shift+Ctrl+K" [
          (flag "move-column-to-monitor-up")
        ])
        (plain "Mod+Shift+Ctrl+L" [
          (flag "move-column-to-monitor-right")
        ])
        (plain "Mod+Page_Down" [
          (flag "focus-workspace-down")
        ])
        (plain "Mod+Page_Up" [
          (flag "focus-workspace-up")
        ])
        (plain "Mod+U" [
          (flag "focus-workspace-down")
        ])
        (plain "Mod+I" [
          (flag "focus-workspace-up")
        ])
        (plain "Mod+Shift+Page_Down" [
          (flag "move-column-to-workspace-down")
        ])
        (plain "Mod+Shift+Page_Up" [
          (flag "move-column-to-workspace-up")
        ])
        (plain "Mod+Shift+U" [
          (flag "move-column-to-workspace-down")
        ])
        (plain "Mod+Shift+I" [
          (flag "move-column-to-workspace-up")
        ])
        (plain "Mod+Ctrl+Page_Down" [
          (flag "move-workspace-down")
        ])
        (plain "Mod+Ctrl+Page_Up" [
          (flag "move-workspace-up")
        ])
        (plain "Mod+Ctrl+U" [
          (flag "move-workspace-down")
        ])
        (plain "Mod+Ctrl+I" [
          (flag "move-workspace-up")
        ])
        (node "Mod+Shift+WheelScrollDown" {cooldown-ms = 150;} [
          (flag "focus-workspace-down")
        ])
        (node "Mod+Shift+WheelScrollUp" {cooldown-ms = 150;} [
          (flag "focus-workspace-up")
        ])
        (plain "Mod+WheelScrollDown" [
          (flag "focus-column-right")
        ])
        (plain "Mod+WheelScrollUp" [
          (flag "focus-column-left")
        ])
        (plain "Mod+1" [
          (leaf "focus-workspace" 1)
        ])
        (plain "Mod+2" [
          (leaf "focus-workspace" 2)
        ])
        (plain "Mod+3" [
          (leaf "focus-workspace" 3)
        ])
        (plain "Mod+4" [
          (leaf "focus-workspace" 4)
        ])
        (plain "Mod+5" [
          (leaf "focus-workspace" 5)
        ])
        (plain "Mod+6" [
          (leaf "focus-workspace" 6)
        ])
        (plain "Mod+7" [
          (leaf "focus-workspace" 7)
        ])
        (plain "Mod+8" [
          (leaf "focus-workspace" 8)
        ])
        (plain "Mod+9" [
          (leaf "focus-workspace" 9)
        ])
        (plain "Mod+Shift+1" [
          (leaf "move-column-to-workspace" 1)
        ])
        (plain "Mod+Shift+2" [
          (leaf "move-column-to-workspace" 2)
        ])
        (plain "Mod+Shift+3" [
          (leaf "move-column-to-workspace" 3)
        ])
        (plain "Mod+Shift+4" [
          (leaf "move-column-to-workspace" 4)
        ])
        (plain "Mod+Shift+5" [
          (leaf "move-column-to-workspace" 5)
        ])
        (plain "Mod+Shift+6" [
          (leaf "move-column-to-workspace" 6)
        ])
        (plain "Mod+Shift+7" [
          (leaf "move-column-to-workspace" 7)
        ])
        (plain "Mod+Shift+8" [
          (leaf "move-column-to-workspace" 8)
        ])
        (plain "Mod+Shift+9" [
          (leaf "move-column-to-workspace" 9)
        ])
        (plain "Mod+F" [
          (flag "toggle-window-floating")
        ])
        (plain "Mod+Shift+F" [
          (flag "toggle-windowed-fullscreen")
        ])
        (plain "Mod+Tab" [
          (flag "focus-window-previous")
        ])
        (plain "Mod+Shift+Tab" [
          (flag "switch-focus-between-floating-and-tiling")
        ])
        (plain "Mod+BracketLeft" [
          (flag "consume-or-expel-window-left")
        ])
        (plain "Mod+BracketRight" [
          (flag "consume-or-expel-window-right")
        ])
        (plain "Mod+Comma" [
          (flag "consume-window-into-column")
        ])
        (plain "Mod+Period" [
          (flag "expel-window-from-column")
        ])
        (node "Mod+R" {repeat = false;} [
          (flag "switch-preset-column-width")
        ])
        (node "Mod+Shift+R" {repeat = false;} [
          (flag "switch-preset-window-height")
        ])
        (plain "Mod+Ctrl+R" [
          (flag "reset-window-height")
        ])
        (node "Mod+M" {repeat = false;} [
          (flag "maximize-column")
        ])
        (node "Mod+Shift+M" {repeat = false;} [
          (flag "fullscreen-window")
        ])
        (plain "Mod+Z" [
          (flag "center-column")
        ])
        (node "Mod+Minus" {repeat = false;} [
          (leaf "set-column-width" "-10%")
        ])
        (node "Mod+Equal" {repeat = false;} [
          (leaf "set-column-width" "+10%")
        ])
        (node "Mod+Shift+Minus" {repeat = false;} [
          (leaf "set-window-height" "-10%")
        ])
        (node "Mod+Shift+Equal" {repeat = false;} [
          (leaf "set-window-height" "+10%")
        ])
        (plain "Print" [
          (flag "screenshot")
        ])
        (plain "Ctrl+Print" [
          (flag "screenshot-screen")
        ])
        (plain "Alt+Print" [
          (flag "screenshot-window")
        ])
        (plain "Mod+Shift+Q" [
          (flag "quit")
        ])
        (plain "Mod+E" [
          (flag "expand-column-to-available-width")
        ])
        (plain "Mod+Shift+S" [
          (flag "toggle-keyboard-shortcuts-inhibit")
        ])
        (plain "Mod+Shift+C" [
          (flag "set-dynamic-cast-window")
        ])
        (plain "Mod+Shift+Ctrl+C" [
          (flag "clear-dynamic-cast-target")
        ])
      ])
    ] # binds
  )
  ++ (
    let
      spawn-at-startup = leaf "spawn-at-startup";
    in [
      (leaf "screenshot-path" "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d_%H:%M:%S.png")
      (plain "hotkey-overlay" [
        (flag "skip-at-startup")
      ])
      (flag "prefer-no-csd")
      (spawn-at-startup [waybar])
      (spawn-at-startup [swaync])
      (spawn-at-startup [swaybg "-i" "${config.home.homeDirectory}/wallpaper/01.png"])
      (spawn-at-startup [polkit-kde-agent])
      (spawn-at-startup [wl-paste "--watch" cliphist "store"])
      (plain "input" [
        (plain "touchpad" [
          (leaf "click-method" "clickfinger")
          (flag "dwt")
          (leaf "scroll-method" "two-finger")
          (leaf "tap-button-map" "left-right-middle")
        ])
      ])
      (plain "cursor" [
        (leaf "hide-after-inactive-ms" 3000)
        (flag "hide-when-typing")
      ])
      (plain "layout" [
        (plain "border" [
          (leaf "width" 4)
          (leaf "active-color" "#7fc8ff")
          (leaf "inactive-color" "#505050")
        ])
        (plain "focus-ring" [
          (flag "off")
          (leaf "width" 4)
          (leaf "active-color" "#7fc8ff")
          (leaf "inactive-color" "#505050")
        ])
        (plain "tab-indicator" [
          (flag "hide-when-single-tab")
        ])
        (plain "preset-column-widths" [
          (leaf "proportion" (1. / 4.))
          (leaf "proportion" (1. / 3.))
          (leaf "proportion" (1. / 2.))
          (leaf "proportion" (2. / 3.))
          (leaf "proportion" (3. / 4.))
          (leaf "proportion" (4. / 4.))
        ])
        (flag "always-center-single-column")
        (leaf "center-focused-column" "never")
        (leaf "default-column-display" "tabbed")
        (plain "default-column-width" [
          (leaf "proportion" (1. / 2.))
        ])
        (flag "empty-workspace-above-first")
        (leaf "gaps" 16)
      ])
      (plain "animations" [
        (plain "window-close" [
          (leaf "spring" {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          })
        ])
      ])
      (plain "environment" [
        (leaf "DISPLAY" DISPLAY)
      ])
    ] # others
  )
  ++ (
    let
      window-rule = plain "window-rule";
      match = leaf "match";
    in [
      (window-rule [
        (leaf "draw-border-with-background" true)
        (leaf "geometry-corner-radius" 12.0)
        (leaf "clip-to-geometry" true)
      ])
      (window-rule [
        (match {app-id = "^showmethekey-gtk$";})
        (leaf "geometry-corner-radius" 0.0)
        (leaf "clip-to-geometry" false)
        (leaf "open-floating" true)
        (leaf "open-focused" false)
        (plain "default-column-width" [
          (leaf "fixed" 300)
        ])
        (plain "default-window-height" [
          (leaf "fixed" 70)
        ])
        (leaf "draw-border-with-background" true)
        (leaf "default-floating-position" {
          relative-to = "bottom-right";
          x = 20;
          y = 20;
        })
        (plain "focus-ring" [
          (flag "off")
        ])
        (plain "border" [
          (flag "off")
        ])
        (plain "shadow" [
          (flag "off")
        ])
        (leaf "baba-is-float" true)
        (leaf "tiled-state" false)
      ])
      (window-rule [
        (match {app-id = "^org\\.keepassxc\\.KeePassXC$";})
        (match {app-id = "^org\\.gnome\\.World\\.Secrets$";})
        (leaf "block-out-from" "screen-capture")
      ])
      (window-rule [
        (match {
          app-id = "^com\\.mitchellh\\.ghostty$";
          is-active = true;
        })
        (leaf "draw-border-with-background" false)
      ])
      (window-rule [
        (match {
          app-id = "^com\\.mitchellh\\.ghostty$";
          is-active = false;
        })
        (leaf "opacity" 0.8)
        (leaf "draw-border-with-background" false)
      ])
      (window-rule [
        (match {is-window-cast-target = true;})
        (plain "focus-ring" [
          (leaf "active-color" "#f38ba8")
          (leaf "inactive-color" "#7d0d2d")
        ])
        (plain "border" [
          (leaf "active-color" "#f38ba8")
          (leaf "inactive-color" "#7d0d2d")
        ])
        (plain "tab-indicator" [
          (leaf "active-color" "#f38ba8")
          (leaf "inactive-color" "#7d0d2d")
        ])
        (plain "shadow" [
          (flag "on")
        ])
      ])
      (window-rule [
        (match {
          app-id = "^org\\.telegram\\.desktop$";
          title = "Media viewer";
        })
        (leaf "open-floating" true)
        (leaf "open-fullscreen" false)
      ])
    ] # window-rule
  )
  ++ (
    let
      layer-rule = plain "layer-rule";
      match = leaf "match";
    in [
      (layer-rule [
        (match {namespace = "^swaync-notification-window$";})
        (match {namespace = "^swaync-control-center$";})
        (leaf "block-out-from" "screen-capture")
      ])
      (layer-rule [
        (match {namespace = "^launcher$";})
        (plain "shadow" [
          (flag "on")
        ])
        (leaf "geometry-corner-radius" 10.0)
      ])
    ] # layer-rule
  )
