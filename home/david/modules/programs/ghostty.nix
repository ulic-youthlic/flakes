{
  config,
  lib,
  ...
}: {
  options = {
    david.programs.ghostty = {
      enable = lib.mkEnableOption "ghostty";
    };
  };
  config = let
    cfg = config.david.programs.ghostty;
  in (lib.mkIf cfg.enable {
    stylix.targets.ghostty.enable = false;
    programs.ghostty = lib.mkMerge [
      {
        enable = true;
        settings = {
          font-family = [
            "MonoLisa"
            "Source Han Sans SC"
          ];
          font-size = lib.mkForce 17;
          theme = "Atom One Dark";
          background-opacity = 0.8;
          confirm-close-surface = "false";
        };
      }
      (lib.mkIf config.youthlic.programs.fish.enable {
        enableFishIntegration = true;
      })
      (lib.mkIf config.youthlic.programs.bash.enable {
        enableBashIntegration = true;
      })
    ];
  });
}
