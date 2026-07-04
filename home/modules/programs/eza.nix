{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.eza;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
  ion-cfg = config.youthlic.programs.ion;
in
{
  options = {
    youthlic.programs.eza = {
      enable = lib.mkEnableOption "eza";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.eza = {
        enable = true;
        colors = "auto";
        icons = "auto";
      };
    })
    (lib.mkIf (cfg.enable && fish-cfg.enable) {
      programs.eza.enableFishIntegration = true;
    })
    (lib.mkIf (cfg.enable && bash-cfg.enable) {
      programs.eza.enableBashIntegration = true;
    })
    (lib.mkIf (cfg.enable && ion-cfg.enable) {
      programs.eza.enableIonIntegration = true;
    })
  ];
}
