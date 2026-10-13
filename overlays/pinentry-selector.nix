{
  den.overlays.pinentry-selector =
    {
      final,
      prev,
      buildBashTool,
    }:
    {
      # Installed as `pinentry`, shadowing the real one on PATH.
      pinentry-selector = buildBashTool {
        pname = "pinentry-selector";
        name = "pinentry";
        # pinentry-gnome3 also ships pinentry-tty.
        runtimeInputs = with prev; [
          pinentry-gnome3
        ];
        meta = {
          description = "Dispatch pinentry to tty or gnome3 based on the session type";
          platforms = prev.lib.platforms.linux;
        };
      };
    };
}
