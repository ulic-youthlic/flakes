{
  den.aspects.shell.eza.homeManager =
    { config, lib, ... }:
    {
      config = lib.mkMerge [
        {
          catppuccin.eza.flavor = "mocha";
          programs.eza = {
            enable = true;
            colors = "auto";
            icons = "auto";
          };
        }
        (lib.mkIf config.programs.fish.enable {
          programs.eza.enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
          programs.eza.enableBashIntegration = true;
        })
        (lib.mkIf config.programs.ion.enable {
          programs.eza.enableIonIntegration = true;
        })
      ];
    };
}
