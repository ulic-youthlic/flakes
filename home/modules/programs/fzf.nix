{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.fzf;
in {
  options = {
    youthlic.programs.fzf = {
      enable = lib.mkEnableOption "fzf";
    };
  };
  config = {
    programs.fzf = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
