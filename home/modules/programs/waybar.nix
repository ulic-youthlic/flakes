{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.waybar;
in
{
  options = {
    youthlic.programs.waybar = {
      enable = lib.mkEnableOption "waybar";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.waybar = {
        enable = true;
        systemd.enable = false;
        settings = [
          {
            layer = "top";
            position = "top";
            modules-left = [
              "niri/workspaces"
              "wlr/taskbar"
            ];
            modules-center = [ "clock" ];
            modules-right = [
              "tray"
              "idle_inhibitor"
              "memory"
              "backlight"
              "pulseaudio"
              "battery"
              "custom/notification"
            ];

            "niri/worksapces" = { };
            "niri/taskbar" = {
              icon-size = 15;
              on-click = "activate";
              on-click-middle = "close";
            };
            "tray" = {
              icon-size = 15;
              spacing = 10;
            };

            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = " ";
                deactivated = " ";
              };
            };

            memory = {
              format = " {percentage}%";
              on-click = lib.getExe pkgs.resources;
            };
            backlight = {
              format = "{icon}{percent}%";
              format-icons = " ";
              on-scroll-up = "${lib.getExe pkgs.brightnessctl} set +1%";
              on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 1%-";
            };

            pulseaudio = {
              format = "{icon}{volume}%";
              format-bluetooth = " {volume}%";
              format-muted = " -%";
              format-source = " {volume}%";
              format-source-muted = " ";
              format-icons = {
                default = [
                  " "
                  " "
                  " "
                ];
                headphone = " ";
                headset = " ";
                hands-free = " ";
              };
              on-click = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-click-right = lib.getExe pkgs.pwvucontrol;
              tooltip-format = "{icon}{desc} {volume}%";
            };

            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon}{capacity}%";
              format-charging = " {capacity}%";
              format-icons = [
                " "
                " "
                " "
                " "
                " "
              ];
              tooltip-format = ''
                {power}W
                {timeTo}'';
            };

            clock = {
              format = "{:%a %b %d %R}";
              calendar.format = {
                months = "<span color='#ff7b63'>{}</span>";
                days = "<span color='#ffffff'>{}</span>";
                weeks = "<span color='#8ff0a4'>W{}</span>";
                weekdays = "<span color='#f8e45c'>{}</span>";
                today = "<span color='#78aeed'><u>{}</u></span>";
              };
              actions = {
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
              tooltip-format = "{calendar}";
            };
            "custom/notification" = {
              "tooltip" = false;
              "format" = "{icon}";
              "format-icons" = {
                "notification" = "<span foreground='red'><sup></sup></span>";
                "none" = "";
                "dnd-notification" = "<span foreground='red'><sup></sup></span>";
                "dnd-none" = "";
              };
              "return-type" = "json";
              "exec" = "swaync-client -swb";
              "on-click" = "swaync-client -t -sw";
              "on-click-right" = "swaync-client -d -sw";
              "escape" = true;
            };
          }
        ];
        style = ''
           * {
            font-family: LXGW Wenkai, Maple Mono NF CN;
            font-weight: bold;
            font-size: 14px;
          }

          window#waybar {
            background: alpha(@theme_base_color, 0.9);
            color: @theme_text_color;
          }

          #custom-notification,
          #workspaces,
          #taskbar button,
          #mode,
          #clock,
          #tray,
          #mpris,
          #idle_inhibitor,
          #backlight,
          #cpu,
          #memory,
          #pulseaudio,
          #battery {
            padding: 0 6px;
          }

          #workspaces button {
            padding: 3px 6px;
          }
          #workspaces button.focused,
          #workspaces button.active {
            color: #78aeed;
          }

          #battery.warning {
            color: #f8e45c;
          }
          #battery.critical {
            color: #ff7b63;
          }
          #battery.charging {
            color: #8ff0a4;
          }
        '';
      };
    })
    (lib.mkIf (cfg.enable && config.stylix.enable) {
      stylix.targets.waybar.enable = false;
    })
  ];
}
