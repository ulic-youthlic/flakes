{ den, inputs, ... }:
{
  den.aspects.noctalia = {
    includes = [ den.aspects.wallpaper ];
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # Script body lives in ./scripts, packaged by the bash overlay.
        gtkThemeSync = pkgs.noctalia-gtk-theme-sync;
      in
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
          # The module defaults to the flake's own build; use the overlay's.
          package = pkgs.noctalia;
          systemd.enable = true;
          settings = lib.recursiveUpdate (fromTOML (builtins.readFile ./noctalia-config.toml)) {
            shell.avatar_path = "${config.home.homeDirectory}/.face";
            wallpaper.directory = "${config.home.homeDirectory}/pic/wallpapers";

            hooks = {
              theme_mode_changed = "${lib.getExe gtkThemeSync}";
              started = "${lib.getExe gtkThemeSync}";
            };
          };
        };
      };
  };
}
