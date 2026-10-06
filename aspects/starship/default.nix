{
  den.aspects.starship.homeManager = {
    catppuccin.starship.flavor = "mocha";
    programs.starship = {
      enable = true;
      enableTransience = true;
      settings =
        let
          config-file = builtins.readFile ./config.toml;
        in
        fromTOML config-file;
    };
    programs.fish.functions = {
      starship_transient_prompt_func = ''
        starship module character
      '';
      starship_transient_rprompt_func = ''
        starship module time
      '';
    };
  };
}
