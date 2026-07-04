{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.fzf;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
in
{
  options = {
    youthlic.programs.fzf = {
      enable = lib.mkEnableOption "fzf";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.fzf = {
        enable = true;
      };
    })
    (lib.mkIf (cfg.enable && fish-cfg.enable) {
      programs.fzf.enableFishIntegration = true;
    })
    (lib.mkIf (cfg.enable && bash-cfg.enable) {
      programs.fzf.enableBashIntegration = true;
    })
  ];
}
