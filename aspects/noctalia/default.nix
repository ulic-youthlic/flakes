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
        gtkThemeSync = pkgs.writeShellApplication {
          name = "noctalia-gtk-theme-sync";
          runtimeInputs = [
            pkgs.dconf
            pkgs.xsettings-theme
            config.programs.noctalia.package
          ];
          text = ''
            mode="''${NOCTALIA_THEME_MODE:-}"

            if [ -z "$mode" ]; then
              mode=$(noctalia msg theme-mode-get 2>/dev/null || true)
            fi
            if [ "$mode" != dark ] && [ "$mode" != light ]; then
              case "$(dconf read /org/gnome/desktop/interface/color-scheme 2>/dev/null || true)" in
                *light*) mode=light ;;
                *) mode=dark ;;
              esac
            fi

            if [ "$mode" = light ]; then
              theme=adw-gtk3
            else
              theme=adw-gtk3-dark
            fi

            dconf write /org/gnome/desktop/interface/gtk-theme "'$theme'"

            if [ -n "''${DISPLAY:-}" ]; then
              xsettings-theme --theme "$theme" || true
            fi
          '';
        };
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
              theme_mode_changed = "${gtkThemeSync}/bin/noctalia-gtk-theme-sync";
              started = "${gtkThemeSync}/bin/noctalia-gtk-theme-sync";
            };
          };
        };
      };
  };
}
