{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.starship;
in {
  options = {
    youthlic.programs.starship = {
      enable = lib.mkEnableOption "starship";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.starship = lib.mkMerge [
      {
        enable = true;
        settings = let
          config-file = builtins.readFile ./config.toml;
        in
          builtins.fromTOML config-file;
      }
      (lib.mkIf config.youthlic.programs.fish.enable {
        enableFishIntegration = true;
      })
      (lib.mkIf config.youthlic.programs.bash.enable {
        enableBashIntegration = true;
      })
    ];
  };
}
