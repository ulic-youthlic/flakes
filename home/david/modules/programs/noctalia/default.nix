{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.david.programs.noctalia;
  inherit (inputs.niri-flake.lib.kdl)
    node
    leaf
    flag
    plain
    ;
  spawn = leaf "spawn";
  noctalia =
    args:
    (spawn (
      [
        "noctalia"
        "msg"
      ]
      ++ args
    ));

  layer-rule = plain "layer-rule";
  match = leaf "match";
in
{
  options = {
    david.programs.noctalia = {
      enable = lib.mkEnableOption "noctalia";
      niriExtraConfig = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
        default = [
          (plain "binds" [
            (plain "Mod+V" [
              (noctalia [
                "panel-toggle"
                "clipboard"
              ])
            ])
            (plain "Mod+Shift+P" [
              (noctalia [
                "session"
                "lock"
              ])
            ])
            (plain "Mod+Space" [
              (noctalia [
                "panel-toggle"
                "launcher"
              ])
            ])
            (node "XF86AudioRaiseVolume"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "volume-up"
                ])
              ]
            )
            (node "XF86AudioLowerVolume"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "volume-down"
                ])
              ]
            )
            (node "XF86AudioMute"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "volume-mute"
                ])
              ]
            )
            (node "XF86AudioMicMute"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "mic-mute"
                ])
              ]
            )
            (node "XF86MonBrightnessUp"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "brightness-up"
                ])
              ]
            )
            (node "XF86MonBrightnessDown"
              [ { allow-when-locked = true; } ]
              [
                (noctalia [
                  "brightness-down"
                ])
              ]
            )
          ])
          (layer-rule [
            (match [ { namespace = "^noctalia-wallpaper"; } ])
            (leaf "place-within-backdrop" [ true ])
          ])
          (layer-rule [
            (match [ { namespace = "^noctalia-(notification|attached-panel)$"; } ])
            (leaf "block-out-from" [ "screen-capture" ])
          ])
          (plain "overview" [
            (plain "workspace-shadow" [
              (flag "off")
            ])
          ])
          (plain "layout" [
            (leaf "background-color" [
              "transparent"
            ])
            (plain "focus-ring" [
              (leaf "active-gradient" [
                {
                  from = "#8288fcff";
                  to = "#8288fc00";
                  angle = 45;
                  "in" = "oklch";
                }
              ])
            ])
          ])
          (plain "switch-events" [
            (plain "lid-close" [
              (noctalia [
                "session"
                "lock-and-suspend"
              ])
            ])
          ])
        ];
        apply =
          configuration:
          config.david.programs.niri.configHelper.validated-config-for (
            inputs.niri-flake.lib.kdl.serialize.nodes configuration
          );
      };
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.noctalia.enable = false;
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = lib.recursiveUpdate (fromTOML (builtins.readFile ./noctalia-config.toml)) {
        shell.avatar_path = "${config.home.homeDirectory}/.face";
        wallpaper.directory = "${config.home.homeDirectory}/${config.david.wallpaper.path}";
      };
    };
  };
}
