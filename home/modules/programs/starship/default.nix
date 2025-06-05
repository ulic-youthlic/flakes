{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.starship;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
in {
  options = {
    youthlic.programs.starship = {
      enable = lib.mkEnableOption "starship";
    };
  };
  config = lib.mkMerge [
    (
      lib.mkIf cfg.enable {
        programs.starship = {
          enable = true;
          enableTransience = true;
          settings = let
            config-file = builtins.readFile ./config.toml;
          in
            builtins.fromTOML config-file;
        };
      }
    )
    (lib.mkIf (cfg.enable && fish-cfg.enable) {
      programs.starship.enableFishIntegration = true;
      programs.fish.functions = {
        starship_transient_prompt_func = ''
          starship module character
        '';
        starship_transient_rprompt_func = ''
          starship module time
        '';
      };
    })
    (lib.mkIf (cfg.enable && bash-cfg.enable) {
      programs.starship.enableBashIntegration = true;
      programs.bash.bashrcExtra = ''
        bleopt prompt_ps1_final='$(starship module character)'
        bleopt prompt_rps1_final='$(starship module time)'
      '';
    })
  ];
}
