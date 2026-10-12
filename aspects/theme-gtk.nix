{
  # adw-gtk3 makes GTK3 apps look like libadwaita. GTK4/libadwaita apps ignore
  # the theme name and follow color-scheme, which noctalia writes.
  #
  # gtk-theme and color-scheme are left out on purpose: noctalia switches them
  # with the day/night schedule (see ./noctalia), and setting them here would
  # pin one variant. On Wayland GTK3 reads these keys from dconf through the
  # settings portal, so no settings.ini is written either.
  den.aspects.theme-gtk.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.adw-gtk3 ];

      dconf.settings."org/gnome/desktop/interface" = lib.mkMerge [
        { icon-theme = "Adwaita"; }
        # home.pointerCursor.gtk only reaches GTK through gtk.enable, which is off,
        # so GTK3 apps would otherwise fall back to the Adwaita cursor.
        (lib.mkIf config.home.pointerCursor.enable {
          cursor-theme = config.home.pointerCursor.name;
          cursor-size = config.home.pointerCursor.gtk.size;
        })
      ];
    };
}
