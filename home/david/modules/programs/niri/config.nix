{
  config,
  lib,
  ...
}:
{
  config.david.programs.niri.config =
    let
      inherit (lib) getExe getExe';
      inherit (lib.nix-kdl.dsl) n;

      default-terminal = getExe config.programs.ghostty.package;
      default-browser = getExe' config.programs.zen-browser.package "zen-twilight";
    in
    (
      let
        spawn = n "spawn";
      in
      [
        (n "binds" [
          (n "Mod+B" [
            (spawn default-browser)
          ])
          (n "Mod+Shift+Slash" [
            (n "show-hotkey-overlay")
          ])
          (n "Mod+T" [
            (spawn default-terminal)
          ])
          (n "Mod+Shift+T" [
            (n "toggle-column-tabbed-display")
          ])
          (n "Mod+Q" [
            (n "close-window")
          ])
          (n "Mod+O" { repeat = false; } [
            (n "toggle-overview")
          ])
          (n "Mod+Left" [
            (n "focus-column-left")
          ])
          (n "Mod+Down" [
            (n "focus-window-down")
          ])
          (n "Mod+Up" [
            (n "focus-window-up")
          ])
          (n "Mod+Right" [
            (n "focus-column-right")
          ])
          (n "Mod+H" [
            (n "focus-column-or-monitor-left")
          ])
          (n "Mod+J" [
            (n "focus-window-or-workspace-down")
          ])
          (n "Mod+K" [
            (n "focus-window-or-workspace-up")
          ])
          (n "Mod+L" [
            (n "focus-column-or-monitor-right")
          ])
          (n "Mod+Shift+Left" [
            (n "move-column-left")
          ])
          (n "Mod+Shift+Down" [
            (n "move-window-down")
          ])
          (n "Mod+Shift+Up" [
            (n "move-window-up")
          ])
          (n "Mod+Shift+Right" [
            (n "move-column-right")
          ])
          (n "Mod+Shift+H" [
            (n "move-column-left-or-to-monitor-left")
          ])
          (n "Mod+Shift+J" [
            (n "move-window-down-or-to-workspace-down")
          ])
          (n "Mod+Shift+K" [
            (n "move-window-up-or-to-workspace-up")
          ])
          (n "Mod+Shift+L" [
            (n "move-column-right-or-to-monitor-right")
          ])
          (n "Mod+Home" [
            (n "focus-column-first")
          ])
          (n "Mod+End" [
            (n "focus-column-last")
          ])
          (n "Mod+Ctrl+Home" [
            (n "move-column-to-first")
          ])
          (n "Mod+Ctrl+End" [
            (n "move-column-to-last")
          ])
          (n "Mod+Ctrl+Left" [
            (n "focus-monitor-left")
          ])
          (n "Mod+Ctrl+Down" [
            (n "focus-monitor-down")
          ])
          (n "Mod+Ctrl+Up" [
            (n "focus-monitor-up")
          ])
          (n "Mod+Ctrl+Right" [
            (n "focus-monitor-right")
          ])
          (n "Mod+Ctrl+H" [
            (n "focus-monitor-left")
          ])
          (n "Mod+Ctrl+J" [
            (n "focus-monitor-down")
          ])
          (n "Mod+Ctrl+K" [
            (n "focus-monitor-up")
          ])
          (n "Mod+Ctrl+L" [
            (n "focus-monitor-right")
          ])
          (n "Mod+Shift+Ctrl+Left" [
            (n "move-column-to-monitor-left")
          ])
          (n "Mod+Shift+Ctrl+Down" [
            (n "move-column-to-monitor-down")
          ])
          (n "Mod+Shift+Ctrl+Up" [
            (n "move-column-to-monitor-up")
          ])
          (n "Mod+Shift+Ctrl+Right" [
            (n "move-column-to-monitor-right")
          ])
          (n "Mod+Shift+Ctrl+H" [
            (n "move-column-to-monitor-left")
          ])
          (n "Mod+Shift+Ctrl+J" [
            (n "move-column-to-monitor-down")
          ])
          (n "Mod+Shift+Ctrl+K" [
            (n "move-column-to-monitor-up")
          ])
          (n "Mod+Shift+Ctrl+L" [
            (n "move-column-to-monitor-right")
          ])
          (n "Mod+Page_Down" [
            (n "focus-workspace-down")
          ])
          (n "Mod+Page_Up" [
            (n "focus-workspace-up")
          ])
          (n "Mod+U" [
            (n "focus-workspace-down")
          ])
          (n "Mod+I" [
            (n "focus-workspace-up")
          ])
          (n "Mod+Shift+Page_Down" [
            (n "move-column-to-workspace-down")
          ])
          (n "Mod+Shift+Page_Up" [
            (n "move-column-to-workspace-up")
          ])
          (n "Mod+Shift+U" [
            (n "move-column-to-workspace-down")
          ])
          (n "Mod+Shift+I" [
            (n "move-column-to-workspace-up")
          ])
          (n "Mod+Ctrl+Page_Down" [
            (n "move-workspace-down")
          ])
          (n "Mod+Ctrl+Page_Up" [
            (n "move-workspace-up")
          ])
          (n "Mod+Ctrl+U" [
            (n "move-workspace-down")
          ])
          (n "Mod+Ctrl+I" [
            (n "move-workspace-up")
          ])
          (n "Mod+Shift+WheelScrollDown" { cooldown-ms = 150; } [
            (n "focus-workspace-down")
          ])
          (n "Mod+Shift+WheelScrollUp" { cooldown-ms = 150; } [
            (n "focus-workspace-up")
          ])
          (n "Mod+WheelScrollDown" [
            (n "focus-column-right")
          ])
          (n "Mod+WheelScrollUp" [
            (n "focus-column-left")
          ])
          (n "Mod+1" [
            (n "focus-workspace" 1)
          ])
          (n "Mod+2" [
            (n "focus-workspace" 2)
          ])
          (n "Mod+3" [
            (n "focus-workspace" 3)
          ])
          (n "Mod+4" [
            (n "focus-workspace" 4)
          ])
          (n "Mod+5" [
            (n "focus-workspace" 5)
          ])
          (n "Mod+6" [
            (n "focus-workspace" 6)
          ])
          (n "Mod+7" [
            (n "focus-workspace" 7)
          ])
          (n "Mod+8" [
            (n "focus-workspace" 8)
          ])
          (n "Mod+9" [
            (n "focus-workspace" 9)
          ])
          (n "Mod+Shift+1" [
            (n "move-column-to-workspace" 1)
          ])
          (n "Mod+Shift+2" [
            (n "move-column-to-workspace" 2)
          ])
          (n "Mod+Shift+3" [
            (n "move-column-to-workspace" 3)
          ])
          (n "Mod+Shift+4" [
            (n "move-column-to-workspace" 4)
          ])
          (n "Mod+Shift+5" [
            (n "move-column-to-workspace" 5)
          ])
          (n "Mod+Shift+6" [
            (n "move-column-to-workspace" 6)
          ])
          (n "Mod+Shift+7" [
            (n "move-column-to-workspace" 7)
          ])
          (n "Mod+Shift+8" [
            (n "move-column-to-workspace" 8)
          ])
          (n "Mod+Shift+9" [
            (n "move-column-to-workspace" 9)
          ])
          (n "Mod+F" [
            (n "toggle-window-floating")
          ])
          (n "Mod+Shift+F" [
            (n "toggle-windowed-fullscreen")
          ])
          (n "Mod+Tab" [
            (n "focus-window-previous")
          ])
          (n "Mod+Shift+Tab" [
            (n "switch-focus-between-floating-and-tiling")
          ])
          (n "Mod+BracketLeft" [
            (n "consume-or-expel-window-left")
          ])
          (n "Mod+BracketRight" [
            (n "consume-or-expel-window-right")
          ])
          (n "Mod+Comma" [
            (n "consume-window-into-column")
          ])
          (n "Mod+Period" [
            (n "expel-window-from-column")
          ])
          (n "Mod+R" { repeat = false; } [
            (n "switch-preset-column-width")
          ])
          (n "Mod+Shift+R" { repeat = false; } [
            (n "switch-preset-window-height")
          ])
          (n "Mod+Ctrl+R" [
            (n "reset-window-height")
          ])
          (n "Mod+M" { repeat = false; } [
            (n "maximize-column")
          ])
          (n "Mod+Shift+M" { repeat = false; } [
            (n "fullscreen-window")
          ])
          (n "Mod+Ctrl+M" { repeat = false; } [
            (n "maximize-window-to-edges")
          ])
          (n "Mod+Z" [
            (n "center-column")
          ])
          (n "Mod+Minus" { repeat = false; } [
            (n "set-column-width" "-10%")
          ])
          (n "Mod+Equal" { repeat = false; } [
            (n "set-column-width" "+10%")
          ])
          (n "Mod+Shift+Minus" { repeat = false; } [
            (n "set-window-height" "-10%")
          ])
          (n "Mod+Shift+Equal" { repeat = false; } [
            (n "set-window-height" "+10%")
          ])
          (n "Print" [
            (n "screenshot")
          ])
          (n "Ctrl+Print" [
            (n "screenshot-screen")
          ])
          (n "Alt+Print" [
            (n "screenshot-window")
          ])
          (n "Mod+Shift+Q" [
            (n "quit")
          ])
          (n "Mod+E" [
            (n "expand-column-to-available-width")
          ])
          (n "Mod+Shift+S" [
            (n "toggle-keyboard-shortcuts-inhibit")
          ])
          (n "Mod+Shift+C" [
            (n "set-dynamic-cast-window")
          ])
          (n "Mod+Shift+Ctrl+C" [
            (n "clear-dynamic-cast-target")
          ])
        ])
      ] # binds
    )
    ++ [
      (n "screenshot-path" "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d_%H:%M:%S.png")
      (n "hotkey-overlay" [
        (n "skip-at-startup")
      ])
      (n "prefer-no-csd")
      (n "input" [
        (n "touchpad" [
          (n "scroll-method" "two-finger")
          (n "middle-emulation")
          (n "tap")
          (n "dwt")
          (n "drag" true)
          (n "click-method" "clickfinger")
          (n "tap-button-map" "left-right-middle")
        ])
      ])
      (n "cursor" [
        (n "hide-after-inactive-ms" 3000)
        (n "hide-when-typing")
      ])
      (n "layout" [
        (n "background-color" "transparent")
        (n "border" [
          (n "off")
          (n "width" 4)
          (n "active-color" "#7fc8ff")
          (n "inactive-color" "#505050")
        ])
        (n "focus-ring" [
          # (n "off")
          (n "width" 4)
          (n "active-color" "#7fc8ff")
          (n "active-gradient" {
            from = "#e00a54";
            to = "#b8de17";
            angle = 45;
          })
          (n "inactive-color" "#505050")
        ])
        (n "tab-indicator" [
          (n "hide-when-single-tab")
        ])
        (n "preset-column-widths" [
          (n "proportion" (1. / 4.))
          (n "proportion" (1. / 3.))
          (n "proportion" (1. / 2.))
          (n "proportion" (2. / 3.))
          (n "proportion" (3. / 4.))
          (n "proportion" (4. / 4.))
        ])
        (n "always-center-single-column")
        (n "center-focused-column" "never")
        (n "default-column-display" "tabbed")
        (n "default-column-width" [
          (n "proportion" (1. / 2.))
        ])
        (n "empty-workspace-above-first")
        (n "gaps" 16)
      ])
      (n "animations" [
        (n "window-close" [
          (n "spring" {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          })
        ])
      ])
      (n "overview" [
        (n "workspace-shadow" [
          (n "off")
        ])
      ])
      (n "blur" [
        (n "passes" 4)
        (n "offset" 4)
        (n "noise" 0.02)
        (n "saturation" 1.0)
      ])
    ] # others
    ++ (
      let
        window-rule = n "window-rule";
        match = n "match";
      in
      [
        (window-rule [
          (n "draw-border-with-background" true)
          (n "geometry-corner-radius" 0.0)
          (n "clip-to-geometry" true)
        ])
        (window-rule [
          (match { app-id = "^org\\.keepassxc\\.KeePassXC$"; })
          (match { app-id = "^org\\.gnome\\.World\\.Secrets$"; })
          (n "block-out-from" "screen-capture")
        ])
        (window-rule [
          (n "background-effect" [
            (n "blur" true)
          ])
        ])
        (window-rule [
          (match { is-active = true; })
          (n "opacity" 1.0)
        ])
        (window-rule [
          (match { is-active = false; })
          (n "opacity" 0.8)
          (n "draw-border-with-background" false)
        ])
        (window-rule [
          (match { app-id = "^Alacritty$"; })
          (match { app-id = "^com\\.mitchellh\\.ghostty$"; })
          (match { app-id = "^neovide$"; })
          (n "draw-border-with-background" false)
          (n "opacity" 0.65)
        ])
        (window-rule [
          (match { app-id = "^org\\.kde\\.polkit-kde-authentication-agent-1$"; })
          (n "open-floating" true)
        ])
        (window-rule [
          (match { app-id = "^swayimg$"; })
          (n "draw-border-with-background" false)
          (n "open-floating" true)
        ])
        (window-rule [
          (match { is-window-cast-target = true; })
          (n "focus-ring" [
            (n "active-color" "#f38ba8")
            (n "inactive-color" "#7d0d2d")
          ])
          (n "border" [
            (n "active-color" "#f38ba8")
            (n "inactive-color" "#7d0d2d")
          ])
          (n "tab-indicator" [
            (n "active-color" "#f38ba8")
            (n "inactive-color" "#7d0d2d")
          ])
          (n "shadow" [
            (n "on")
          ])
        ])
        (window-rule [
          (match {
            app-id = "^org\\.telegram\\.desktop$";
            title = "Media viewer";
          })
          (match {
            app-id = "^QQ$";
            title = "图片查看器";
          })
          (n "open-floating" true)
          (n "open-fullscreen" false)
        ])
        (window-rule [
          (match {
            app-id = "^wechat$";
            title = "^wechat$";
          })
          (n "open-focused" false)
        ])
        (window-rule [
          (match {
            app-id = "^steam$";
            title = "^notificationtoasts_\\d+_desktop$";
          })
          (n "open-floating" true)
          (n "open-focused" false)
          (n "default-floating-position" {
            x = 10;
            y = 10;
            "relative-to" = "bottom-right";
          })
          (n "clip-to-geometry" false)
        ])
        (window-rule [
          (match {
            app-id = "^zen-twilight$";
            title = "^画中画$";
          })
          (n "open-floating" true)
          (n "open-focused" false)
        ])
      ] # window-rule
    );
}
