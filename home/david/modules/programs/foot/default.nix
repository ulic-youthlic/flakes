{
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.foot;
in {
  options = {
    david.programs.foot = {
      enable = lib.mkEnableOption "foot";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = builtins.fromINI (builtins.readFile ./foot.ini);
    };
  };
}
