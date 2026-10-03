{
  den.aspects.shell.zoxide.homeManager =
    { config, lib, ... }:
    {
      config = lib.mkMerge [
        {
          programs.zoxide = {
            enable = true;
          };
        }
        (lib.mkIf config.programs.fish.enable {
          programs.zoxide.enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
          programs.zoxide.enableBashIntegration = true;
        })
      ];
    };
}
