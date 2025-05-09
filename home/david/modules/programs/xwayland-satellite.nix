{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.david.programs.xwayland-satellite;
in {
  options = {
    david.programs.xwayland-satellite = {
      enable = lib.mkEnableOption "xwayland-satellite";
      DISPLAY = lib.mkOption {
        type = lib.types.str;
        example = ":1";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user = {
      services."xwayland-satellite" = {
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Unit = {
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.xwayland-satellite} ${cfg.DISPLAY}";
          Restart = "on-failure";
        };
      };
    };
  };
}
