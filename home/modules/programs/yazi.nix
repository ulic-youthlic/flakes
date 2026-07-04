{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.programs.yazi;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
in
{
  options = {
    youthlic.programs.yazi = {
      enable = lib.mkEnableOption "yazi";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        starship
      ];
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
                name = "*";
                run = "git";
              }
              {
                id = "git";
                name = "*/";
                run = "git";
              }
            ];
            prepend_previewers = [
              {
                name = "*.md";
                run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} --style dark --width $w $1";
              }
              {
                name = "*/";
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
    })
    (lib.mkIf (cfg.enable && fish-cfg.enable) {
      programs.yazi.enableFishIntegration = true;
    })
    (lib.mkIf (cfg.enable && bash-cfg.enable) {
      programs.yazi.enableBashIntegration = true;
    })
  ];
}
