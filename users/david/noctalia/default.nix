{
  den,
  inputs,
  kdl,
  ...
}:
{
  den.aspects.david.noctalia = {
    # The wallpaper directory noctalia shows comes from david.wallpaper.
    includes = [ den.aspects.david.wallpaper ];
    homeManager =
      {
        config,
        lib,
        ...
      }:
      let
        inherit (kdl.dsl) n;
        spawn = n "spawn";
        noctalia = spawn "noctalia" "msg";

        layer-rule = n "layer-rule";
        match = n "match";
      in
      {
        # Keyed so a second import into the same home is deduplicated.
        imports = [
          {
            key = "inputs:noctalia/homeModules.default";
            imports = [ inputs.noctalia.homeModules.default ];
          }
        ];
        options = {
          catppuccin.noctalia.enable = false;
          david.programs.noctalia = {
            niriExtraConfig = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [
                (n "binds" [
                  (n "Mod+V" [
                    (noctalia "panel-toggle" "clipboard")
                  ])
                  (n "Mod+Shift+P" [
                    (noctalia "session" "lock")
                  ])
                  (n "Mod+Space" [
                    (noctalia "panel-toggle" "launcher")
                  ])
                  (n "XF86AudioRaiseVolume" { allow-when-locked = true; } [
                    (noctalia "volume-up")
                  ])
                  (n "XF86AudioLowerVolume" { allow-when-locked = true; } [
                    (noctalia "volume-down")
                  ])
                  (n "XF86AudioMute" { allow-when-locked = true; } [
                    (noctalia "volume-mute")
                  ])
                  (n "XF86AudioMicMute" { allow-when-locked = true; } [
                    (noctalia "mic-mute")
                  ])
                  (n "XF86MonBrightnessUp" { allow-when-locked = true; } [
                    (noctalia "brightness-up")
                  ])
                  (n "XF86MonBrightnessDown" { allow-when-locked = true; } [
                    (noctalia "brightness-down")
                  ])
                ])
                (layer-rule [
                  (match { namespace = "^noctalia-wallpaper"; })
                  (n "place-within-backdrop" true)
                ])
                (layer-rule [
                  (match { namespace = "^noctalia-(notification|attached-panel)$"; })
                  (n "block-out-from" "screen-capture")
                ])
                (n "overview" [
                  (n "workspace-shadow" [
                    (n "off")
                  ])
                ])
                (n "layout" [
                  (n "background-color" "transparent")
                  (n "focus-ring" [
                    (n "active-gradient" {
                      from = "#8288fcff";
                      to = "#8288fc00";
                      angle = 45;
                      "in" = "oklch";
                    })
                  ])
                ])
                (n "switch-events" [
                  (n "lid-close" [
                    (noctalia "session" "lock-and-suspend")
                  ])
                ])
              ];
              apply = lib.flip lib.pipe [
                kdl.formats.v1
                config.david.programs.niri.configHelper.validated-config-for
              ];
            };
          };
        };
        config = {
          programs.noctalia = {
            enable = true;
            systemd.enable = true;
            settings = lib.recursiveUpdate (fromTOML (builtins.readFile ./noctalia-config.toml)) {
              shell.avatar_path = "${config.home.homeDirectory}/.face";
              wallpaper.directory = "${config.home.homeDirectory}/${config.david.wallpaper.path}";
            };
          };
        };
      };
  };
}
