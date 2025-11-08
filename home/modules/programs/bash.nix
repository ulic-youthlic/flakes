{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.bash;
in {
  options = {
    youthlic.programs.bash = {
      enable = lib.mkEnableOption "bash";
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
      };
    };
  };
}
