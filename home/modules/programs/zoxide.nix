{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.zoxide;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
in {
  options = {
    youthlic.programs.zoxide = {
      enable = lib.mkEnableOption "zoxide";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.zoxide = {
        enable = true;
      };
    })
    (lib.mkIf (cfg.enable && fish-cfg.enable) {
      programs.zoxide.enableFishIntegration = true;
    })
    (lib.mkIf (cfg.enable && bash-cfg.enable) {
      programs.zoxide.enableBashIntegration = true;
    })
  ];
}
