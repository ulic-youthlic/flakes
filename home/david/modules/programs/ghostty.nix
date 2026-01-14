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
    programs.ghostty = lib.mkMerge [
      {
        enable = true;
        settings = {
          # font-family = "Maple Mono NF CN";
          font-feature = [
            "calt"
            "zero"
            "cv03"
            "ss08"
          ];
          font-size = lib.mkForce 17;
          theme = lib.mkForce "Atom One Dark";
          background-opacity = lib.mkForce 0.8;
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
