{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.david.programs.noctalia;
  inherit (inputs.niri-flake.lib.kdl) node leaf flag plain;
  spawn = leaf "spawn";
  noctalia = args: (spawn (["noctalia-shell" "ipc" "call"] ++ args));

  layer-rule = plain "layer-rule";
  match = leaf "match";
in {
  options = {
    david.programs.noctalia = {
      enable = lib.mkEnableOption "noctalia";
      niriExtraConfig = lib.mkOption {
        type = inputs.niri-flake.lib.kdl.types.kdl-document;
        default = [
          (plain "binds" [
            (plain "Mod+V" [(noctalia ["launcher" "clipboard"])])
            (plain "Mod+Shift+P" [(noctalia ["lockScreen" "lock"])])
            (plain "Mod+Space" [(noctalia ["launcher" "toggle"])])
            (node "XF86AudioRaiseVolume" [{allow-when-locked = true;}]
              [(noctalia ["volume" "increase"])])
            (node "XF86AudioLowerVolume" [{allow-when-locked = true;}]
              [(noctalia ["volume" "decrease"])])
            (node "XF86AudioMute" [{allow-when-locked = true;}]
              [(noctalia ["volume" "muteOutput"])])
            (node "XF86AudioMicMute" [{allow-when-locked = true;}]
              [(noctalia ["volume" "muteInput"])])
          ])
          (layer-rule [
            (match [{namespace = "^noctalia-wallpaper-.*$";}])
            (leaf "place-within-backdrop" [true])
          ])
          (layer-rule [
            (match [{namespace = "^noctalia-notifications-.*$";}])
            (leaf "block-out-from" ["screen-capture"])
          ])
          (plain "layout" [
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
        ];
        apply = configuration: config.david.programs.niri.configHelper.validated-config-for (inputs.niri-flake.lib.kdl.serialize.nodes configuration);
      };
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.noctalia-shell.enable = false;
    home.packages = [pkgs.app2unit pkgs.gpu-screen-recorder];
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      plugins = builtins.fromJSON (builtins.readFile ./plugins.json);
      pluginSettings = let
        enabledPlugins = with lib;
          flip pipe [
            (filterAttrs (_name: settings: settings.enabled or false))
            builtins.attrNames
          ]
          config.programs.noctalia-shell.plugins.states;
        staticSettings = lib.genAttrs enabledPlugins (name: let
          pluginSettingPath = ./plugin + "/${name}.json";
        in
          if lib.pathIsRegularFile pluginSettingPath
          then builtins.fromJSON (builtins.readFile pluginSettingPath)
          else {});
      in
        lib.recursiveUpdate
        staticSettings {
          screen-recorder.directory = "${config.xdg.userDirs.videos}/records";
        };
      settings =
        lib.recursiveUpdate
        (builtins.fromJSON (builtins.readFile ./settings.json))
        {
          general.avatarImage = "${config.home.homeDirectory}/.face";
          wallpaper.directory = "${config.home.homeDirectory}/${config.david.wallpaper.path}";
        };
    };
  };
}
