# shellcheck shell=bash
# Body only: buildBashTool wraps this with a shebang, `set -euo pipefail` and a
# PATH built from the overlay's runtimeInputs.
#
# Installed as `pinentry`, shadowing the real one on PATH.

# gpg passes the client's session type to the agent, and SSH logins are "tty".
# Prompt in that terminal: gpg-agent has the desktop's D-Bus, so pinentry-gnome3
# would open its dialog on the desktop instead.
if [ "${XDG_SESSION_TYPE-}" = tty ]; then
  exec pinentry-tty "$@"
fi

# pinentry-gnome3 handles every other case, falling back to curses without D-Bus
# or a GCR prompter.
exec pinentry-gnome3 "$@"
