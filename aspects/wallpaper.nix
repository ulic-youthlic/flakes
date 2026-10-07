{
  den.aspects.wallpaper.homeManager =
    { pkgs, ... }:
    {
      home.file."pic/wallpapers" = {
        force = true;
        recursive = true;
        source = toString pkgs.wallpapers;
      };
    };
}
