{
  lib,
  config,
  pkgs,
  osConfig ? null,
  ...
}: let
  cfg = config.david.programs.fcitx5-reload;
  fcitx5 = lib.getExe' osConfig.i18n.inputMethod.package "fcitx5";
in {
  options = {
    david.programs.fcitx5-reload = {
      enable = lib.mkEnableOption "fcitx5-reload";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services = {
      "fcitx5-reload" = {
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Unit = {
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${fcitx5} --replace";
          Restart = "on-failure";
        };
      };
    };
  };
}
