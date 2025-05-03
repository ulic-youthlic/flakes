{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.zoxide;
in {
  options = {
    youthlic.programs.zoxide = {
      enable = lib.mkEnableOption "zoxide";
    };
  };
  config = {
    programs.zoxide = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
