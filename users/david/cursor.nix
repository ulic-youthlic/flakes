{
  den.aspects.david.cursor.homeManager =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        x11.enable = true;
        name = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 24;
      };
    };
}
