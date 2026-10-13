{
  den.overlays.noctalia-gtk-theme-sync =
    {
      final,
      prev,
      buildBashTool,
    }:
    {
      noctalia-gtk-theme-sync = buildBashTool {
        pname = "noctalia-gtk-theme-sync";
        # Resolve through `final`, not `prev`: overlays compose in name order, so
        # `xsettings-theme` (later alphabetically) is not in `prev` here. Also,
        # hyphenated names cannot come from `with prev;`.
        runtimeInputs = [
          final.dconf
          final.noctalia
          final.xsettings-theme
        ];
        meta = {
          description = "Keep GTK theme name and color-scheme in step with the Noctalia theme mode";
          platforms = prev.lib.platforms.linux;
        };
      };
    };
}
