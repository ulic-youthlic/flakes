{
  config,
  lib,
  ...
}:
let
  cfg = config.david.programs.noctalia;
  inherit (lib.nix-kdl.dsl) n;
  spawn = n "spawn";
  noctalia = spawn "noctalia" "msg";

  layer-rule = n "layer-rule";
  match = n "match";
in
{
  options = {
    david.programs.noctalia = {
      enable = lib.mkEnableOption "noctalia";
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
          lib.nix-kdl.formats.v1
          config.david.programs.niri.configHelper.validated-config-for
        ];
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
