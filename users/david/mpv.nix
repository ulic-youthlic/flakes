{
  den.aspects.david.mpv.homeManager =
    {
      pkgs,
      ...
    }:
    {
      config = {
        catppuccin.mpv.flavor = "mocha";
        programs.mpv = {
          enable = true;
          scripts = [
            pkgs.mpvScripts.uosc
            pkgs.mpvScripts.thumbfast
          ];
        };
      };
    };
}
