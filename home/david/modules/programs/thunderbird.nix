{
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.thunderbird;
in {
  options = {
    david.programs.thunderbird = {
      enable = lib.mkEnableOption "thunderbird";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles = {
        default = {
          withExternalGnupg = true;
          isDefault = true;
        };
      };
    };
  };
}
