{
  den.aspects.yazi.homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      catppuccin.yazi.flavor = "mocha";
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        plugins = {
          inherit (pkgs.yaziPlugins)
            ouch
            starship
            piper
            chmod
            smart-enter
            git
            full-border
            ;
        };
        initLua =
          #lua
          ''
            require("full-border"):setup()
            require("starship"):setup()
            require("smart-enter"):setup({
              open_multi = true,
            })
            require("git"):setup()
          '';
        settings = {
          plugin = {
            prepend_fetchers = [
              {
                id = "git";
                url = "*";
                run = "git";
                group = "star";
              }
              {
                id = "git";
                url = "*/";
                run = "git";
                group = "star-slash";
              }
            ];
            prepend_previewers = [
              {
                mime = "text/markdown";
                run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} --style dark --width $w $1";
              }
              {
                url = "*/";
                run = "piper -- ${lib.getExe pkgs.eza} '-TL=3' '--color=always' '--icons=always' --group-directories-first --no-quotes \"$1\"";
              }
            ];
          };
        };
        keymap = {
          mgr = {
            prepend_keymap = [
              {
                on = [
                  "c"
                  "m"
                ];
                run = "plugin chmod";
                desc = "Chmod on selected files";
              }
              {
                on = [ "l" ];
                run = "plugin smart-enter";
                desc = "Enter the child directory, or open the file";
              }
            ];
          };
        };
      };
    };
}
