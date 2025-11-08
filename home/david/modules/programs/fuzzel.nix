{
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.fuzzel;
in {
  options = {
    david.programs.fuzzel = {
      enable = lib.mkEnableOption "fuzzel";
    };
  };
  config = {
    programs.fuzzel = lib.mkIf cfg.enable {
      enable = true;
      settings = {
        main = {
          prompt = "'λ '";
          dpi-aware = true;
        };
      };
    };
  };
}
