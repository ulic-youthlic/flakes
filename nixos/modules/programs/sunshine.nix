{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.sunshine;
in
{
  options = {
    youthlic.programs.sunshine = {
      enable = lib.mkEnableOption "sunsine";
    };
  };
  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      # settings = {};
      openFirewall = true;
      # applications = {};
    };
  };
}
