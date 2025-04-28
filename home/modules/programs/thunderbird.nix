{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.thunderbird;
in {
  options = {
    youthlic.programs.thunderbird = {
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
