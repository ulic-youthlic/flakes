{
  den.aspects.david.wallpaper.homeManager =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options = {
        david.wallpaper = {
          path = lib.mkOption {
            type = lib.types.str;
            default = "pic/wallpapaers";
          };
        };
      };
      config = {
        home.file."${config.david.wallpaper.path}" = {
          force = true;
          recursive = true;
          source = toString pkgs.wallpapers;
        };
      };
    };
}
