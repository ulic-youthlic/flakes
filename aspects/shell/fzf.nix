{
  den.aspects.shell.fzf.homeManager =
    { config, lib, ... }:
    {
      config = lib.mkMerge [
        {
          catppuccin.fzf.flavor = "mocha";
          programs.fzf = {
            enable = true;
          };
        }
        (lib.mkIf config.programs.fish.enable {
          programs.fzf.enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
          programs.fzf.enableBashIntegration = true;
        })
        (lib.mkIf config.programs.atuin.enable {
          programs.fzf.historyWidget.command = "";
        })
      ];
    };
}
