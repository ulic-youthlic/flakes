{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    youthlic.programs.gpg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = ''
          whether enable gpg
        '';
      };
    };
  };
  config =
    let
      cfg = config.youthlic.programs.gpg;
    in
    lib.mkIf cfg.enable {
      services.gpg-agent = lib.mkMerge [
        {
          enable = true;
          enableSshSupport = true;
          pinentryPackage = pkgs.pinentry-curses;
        }
        (lib.mkIf config.youthlic.programs.fish.enable {
          enableFishIntegration = true;
        })
        (lib.mkIf config.youthlic.programs.bash.enable {
          enableBashIntegration = true;
        })
      ];
      programs.gpg = {
        enable = true;
        mutableKeys = true;
        mutableTrust = true;
        publicKeys = [
          {
            source = ./public-key.txt;
            trust = "ultimate";
          }
        ];
      };
    };
}
