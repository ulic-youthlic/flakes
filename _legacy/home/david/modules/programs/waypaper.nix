{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.david.programs.waypaper;
in
{
  options = {
    david.programs.waypaper = {
      enable = lib.mkEnableOption "waypaper";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      waypaper
      socat
      mpvpaper
    ];
    systemd.user = {
      timers."waypaper" = {
        Unit = {
          Description = "Set a random wallpaper every 10 minutes";
        };
        Timer = {
          Persistent = true;
          OnCalendar = "*:0/10";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      services."waypaper" = {
        Unit = {
          Description = "Set a random wallpaper with waypaper";
        };
        Service = {
          Type = "oneshot";
          ExecStart = lib.escapeShellArgs [
            (lib.getExe pkgs.waypaper)
            "--random"
          ];
        };
      };
    };
  };
}
