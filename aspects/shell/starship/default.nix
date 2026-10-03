{
  den.aspects.shell.starship.homeManager =
    { config, lib, ... }:
    {
      config = lib.mkMerge [
        {
          catppuccin.starship.flavor = "mocha";
          programs.starship = {
            enable = true;
            enableTransience = true;
            settings =
              let
                config-file = builtins.readFile ./config.toml;
              in
              builtins.fromTOML config-file;
          };
        }
        (lib.mkIf config.programs.fish.enable {
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
        (lib.mkIf config.programs.bash.enable {
          programs.starship.enableBashIntegration = true;
        })
        (lib.mkIf config.programs.ion.enable {
          programs.starship.enableIonIntegration = true;
        })
      ];
    };
}
