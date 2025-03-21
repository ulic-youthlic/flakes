{ lib, config, ... }:
let
  cfg = config.david.programs.wluma;
in
{
  options = {
    david.programs.wluma = {
      enable = lib.mkEnableOption "wluma";
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.programs.wluma.config = ./config.toml;
  };
}
