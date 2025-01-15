{ pkgs }:
pkgs.writeShellApplication {
  name = "pinentry";
  runtimeInputs = with pkgs; [
    pinentry-all
  ];
  text = ''
    if [ -v XDG_SESSION_TYPE ]; then
      case $XDG_SESSION_TYPE in
        tty)
          pinentry-tty;;
        *)
          pinentry-qt;;
      esac
    elif [ -v SSH_CLIENT ] && [ -n "$SSH_CLIENT" ]; then
      pinentry-tty
    elif [ -v WAYLAND_DISPLAY ] && [ -n "$WAYLAND_DISPLAY" ]; then
      pinentry-qt
    elif [ -v DISPLAY ] && [ -n "$DISPLAY" ]; then
      pinentry-qt
    else
      pinentry-tty
    fi
  '';
}
