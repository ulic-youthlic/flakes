{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.swaync;
in {
  options = {
    youthlic.programs.swaync = {
      enable = lib.mkEnableOption "swaync";
      systemd.enable = lib.mkEnableOption "systemd service for swaync";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.swaync = {
        enable = true;
      };
    })
    (lib.mkIf (!cfg.systemd.enable) {
      systemd.user.services.swaync = lib.mkForce {};
    })
  ];
}
