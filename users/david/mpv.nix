{
  den.aspects.david.mpv.homeManager =
    {
      lib,
      config,
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
