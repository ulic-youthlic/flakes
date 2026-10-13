{
  den.aspects.theme-gtk.homeManager =
    { pkgs, ... }:
    {
      gtk.enable = true;

      home = {
        sessionVariables = {
          GDK_CSD = 0;
        };
        packages = [
          pkgs.adw-gtk3
          pkgs.xsettings-theme
        ];
      };
    };
}
