{ den, inputs, ... }:
{
  den.aspects.noctalia = {
    # The wallpaper directory noctalia shows comes from wallpaper.
    includes = [ den.aspects.wallpaper ];
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # Noctalia resolves `auto` against its day/night schedule and writes
        # org.gnome.desktop.interface color-scheme itself, which GTK4/libadwaita
        # follow. GTK3 has no color-scheme support at all (the key is absent from
        # GTK3's Wayland translation table), so its variant has to be selected by
        # theme *name* — that is the one thing this script exists to do.
        #
        # theme_mode_changed supplies NOCTALIA_THEME_MODE. `started` has no mode in
        # the environment (and the first resolve at login does not fire
        # theme_mode_changed), so ask the shell over IPC, which is up before
        # startup hooks run. Noctalia writes color-scheme with an async `dconf
        # write`, so that key is only a fallback in case IPC times out.
        gtkThemeSync = pkgs.writeShellApplication {
          name = "noctalia-gtk-theme-sync";
          runtimeInputs = [
            pkgs.dconf
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
