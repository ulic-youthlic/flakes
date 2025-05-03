{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.eza;
in {
  options = {
    youthlic.programs.eza = {
      enable = lib.mkEnableOption "eza";
    };
  };
  config = {
    programs.eza = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
