{
  # adw-gtk3 makes GTK3 apps look like libadwaita. GTK4/libadwaita apps ignore
  # the theme name and follow color-scheme, which noctalia writes.
  #
  # gtk.theme and gtk.colorScheme are left unset on purpose: noctalia drives both
  # from the day/night schedule (see ./noctalia), and setting them here would pin
  # one variant into a read-only store path. Everything the gtk module writes for
  # us (the cursor, via home.pointerCursor) is variant-independent.
  den.aspects.theme-gtk.homeManager =
    { pkgs, ... }:
    {
      gtk.enable = true;

      home.packages = [
        # Puts share/themes/adw-gtk3{,-dark} on XDG_DATA_DIRS, where GTK looks up
        # the theme named by org.gnome.desktop.interface gtk-theme.
        pkgs.adw-gtk3

        # X11 GTK apps can't see dconf: they read the XSETTINGS property instead
        # (see ./noctalia). This rewrites the theme keys in it.
        pkgs.xsettings-theme
      ];
    };
}
