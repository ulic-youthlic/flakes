{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.fish;
in {
  options = {
    youthlic.programs.fish = {
      enable = lib.mkEnableOption "fish";
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          fish_vi_key_bindings
        '';
        functions = {
          __fish_command_not_found_handler = {
            body = "__fish_default_command_not_found_handler $argv[1]";
            onEvent = "fish_command_not_found";
          };
          fish_greeting = {
            body = ''
              fastfetch
            '';
          };
        };
      };
      fastfetch.enable = true;
    };
  };
}
