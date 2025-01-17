{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  fish-cfg = config.youthlic.programs.fish;
  bash-cfg = config.youthlic.programs.bash;
  cfg-helper =
    conf:
    mkMerge [
      conf
      (mkIf fish-cfg.enable {
        enableFishIntegration = true;
      })
      (mkIf bash-cfg.enable {
        enableBashIntegration = true;
      })
    ];
in
{
  options = {
    youthlic.programs = {
      fish = {
        enable =mkEnableOption "fish";
      };
      bash = {
        enable = mkEnableOption "bash";
      };
    };
  };
  config = mkMerge [
    {
      programs = {
        zoxide = cfg-helper {
          enable = true;
        };
        yazi = cfg-helper {
          enable = true;
        };
        fzf = cfg-helper {
          enable = true;
        };
        eza = cfg-helper {
          enable = true;
        };
      };
    }
    (mkIf fish-cfg.enable {
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
    })
    (mkIf bash-cfg.enable {
      programs = {
        bash = {
          enable = true;
        };
      };
    })
  ];
}
