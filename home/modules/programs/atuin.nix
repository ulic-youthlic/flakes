{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.atuin;
in {
  options = {
    youthlic.programs.atuin = {
      enable = lib.mkEnableOption "atuin";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.atuin = {
        daemon = {
          enable = true;
          logLevel = "trace";
        };
        enable = true;
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
        };
      };
    })
    (lib.mkIf config.youthlic.programs.fish.enable {
      programs.atuin.enableFishIntegration = true;
    })
    (lib.mkIf config.youthlic.programs.bash.enable {
      programs.atuin.enableBashIntegration = true;
    })
  ];
}
