{
  den.overlays.pinentry-selector =
    { prev }:
    let
      inherit (prev) writeShellApplication pinentry-gnome3;
    in
    {
      pinentry-selector = writeShellApplication {
        name = "pinentry";
        # pinentry-gnome3 also ships pinentry-tty.
        runtimeInputs = [
          pinentry-gnome3
        ];
        text = # bash
          ''
            # gpg passes the client's session type to the agent, and SSH
            # logins are "tty". Prompt in that terminal: gpg-agent has the
            # desktop's D-Bus, so pinentry-gnome3 would open its dialog on the
            # desktop instead. pinentry-gnome3 handles every other case,
            # falling back to curses without D-Bus or a GCR prompter.
            if [ "''${XDG_SESSION_TYPE-}" = tty ]; then
              exec pinentry-tty "$@"
            fi
            exec pinentry-gnome3 "$@"
          '';
      };
    };
}
