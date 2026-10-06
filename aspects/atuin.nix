{
  den.aspects.atuin.homeManager = {
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
    # Atuin owns Ctrl-R when both history integrations are selected.
    programs.fzf.historyWidget.command = "";
  };
}
