{ den, inputs, ... }:
{
  den.aspects.david.noctalia = {
    # The wallpaper directory noctalia shows comes from wallpaper.
    includes = [ den.aspects.wallpaper ];
    homeManager =
      { config, lib, ... }:
      {
        # Keyed so a second import into the same home is deduplicated.
        imports = [
          {
            key = "inputs:noctalia/homeModules.default";
            imports = [ inputs.noctalia.homeModules.default ];
          }
        ];
        config.programs.noctalia = {
          enable = true;
          systemd.enable = true;
          settings = lib.recursiveUpdate (fromTOML (builtins.readFile ./noctalia-config.toml)) {
            shell.avatar_path = "${config.home.homeDirectory}/.face";
            wallpaper.directory = "${config.home.homeDirectory}/pic/wallpapers";
          };
        };
      };
  };
}
