{
  den.aspects.david.ghostty.homeManager =
    { config, lib, ... }:
    {
      catppuccin.ghostty.enable = false;
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
        (lib.mkIf config.programs.fish.enable {
          enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
          enableBashIntegration = true;
        })
      ];
    };
}
