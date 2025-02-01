{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.wluma;
in
{
  options = {
    youthlic.programs.wluma = {
      enable = lib.mkEnableOption "wluma";
      config = lib.mkOption {
        type = lib.types.path;
        example = ./config.toml;
        description = ''
          path to config file of wluma
        '';
      };
      package = lib.mkOption {
        type = lib.types.package;
        example = pkgs.wluam;
        default = pkgs.wluma;
        description = ''
          pakcage of wluma
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
    xdg.configFile."wluma/config.toml" = {
      enable = true;
      source = cfg.config;
    };
    systemd.user.services.wluma = {
      Unit = {
        Description = "Adjusting screen brightness based on screen contents and amount of ambient light";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = [ "${lib.getExe cfg.package}" ];
        Restart = "always";
        EnvironmentFile = [ "-%E/wluma/service.conf" ];
        PrivateNetwork = true;
        PrivateMounts = false;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
