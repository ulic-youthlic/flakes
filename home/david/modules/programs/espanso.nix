{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.david.programs.espanso;
in {
  options = {
    david.programs.espanso = {
      enable = lib.mkEnableOption "espanso";
    };
  };
  config = lib.mkIf cfg.enable {
    services.espanso = {
      enable = true;
      package = pkgs.espanso-wayland;
      configs = {
        default = {};
      };
      matches = {
        base = {
          matches = [
            {
              trigger = ":date";
              replace = "{{date}}";
              vars = [
                {
                  name = "date";
                  type = "date";
                  params = {
                    format = "%Y-%m-%d";
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
