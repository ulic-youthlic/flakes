{ lib, config, ... }:
let
  cfg = config.youthlic.programs.upower;
in
{
  options = {
    youthlic.programs.upower = {
      enable = lib.mkEnableOption "upower";
    };
  };
  config = lib.mkIf cfg.enable {
    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
    };
  };
}
