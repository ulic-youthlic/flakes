{
  den.aspects.atuin.homeManager =
    { config, lib, ... }:
    {
      config = lib.mkMerge [
        {
          catppuccin.atuin.flavor = "mocha";
          programs.atuin = {
            daemon = {
              enable = true;
              logLevel = "trace";
            };
            enable = true;
            flags = [
              "--disable-up-arrow"
            ];
            settings = {
              auto_sync = true;
              update_check = false;
              style = "full";
              history_filter = [
                "^ .*"
              ];
              enter_accept = false;
              keymap_mode = "vim-insert";
              sync.records = true;
              search_mode = "skim";
            };
          };
        }
        (lib.mkIf config.programs.fish.enable {
          programs.atuin.enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
          programs.atuin.enableBashIntegration = true;
        })
      ];
    };
}
