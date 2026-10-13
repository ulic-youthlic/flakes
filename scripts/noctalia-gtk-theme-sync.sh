# shellcheck shell=bash
# Body only: buildBashTool wraps this with a shebang, `set -euo pipefail` and a
# PATH built from the overlay's runtimeInputs.
#
# Runs from Noctalia's theme_mode_changed and started hooks.
#
# theme_mode_changed furnishes NOCTALIA_THEME_MODE. `started` has no mode in the
# environment (and the first resolve at login does not fire theme_mode_changed),
# so ask the shell over IPC, which is up before startup hooks run. Noctalia
# writes color-scheme with an async write, so that key is only a fallback in case
# IPC times out.

mode="${NOCTALIA_THEME_MODE:-}"

if [ -z "$mode" ]; then
  mode=$(noctalia msg theme-mode-get 2>/dev/null || true)
fi
if [ "$mode" != dark ] && [ "$mode" != light ]; then
  case "$(dconf read /org/gnome/desktop/interface/color-scheme 2>/dev/null || true)" in
  *light*) mode=light ;;
  *) mode=dark ;;
  esac
fi

if [ "$mode" = light ]; then
  theme=adw-gtk3
else
  theme=adw-gtk3-dark
fi

# gtk-theme is what GTK3 apps follow. GTK3 has no color-scheme concept at all, so
# its light/dark variant can only be selected by theme name.
dconf write /org/gnome/desktop/interface/gtk-theme "'$theme'"

# X11 GTK apps read XSETTINGS, not dconf, so they need the same theme name written
# to the XSETTINGS property. xwayland-satellite owns the selection (for DPI); the
# helper rewrites that property in place and preserves the satellite's keys.
# No-op when no X display exists.
if [ -n "${DISPLAY:-}" ]; then
  xsettings-theme --theme "$theme" || true
fi
