{
  pkgs,
  config,
  lib,
  outputs,
  ...
}:
{
  options = {
    youthlic.programs.gpg = {
      enable = lib.mkEnableOption "gpg";
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
          pinentryPackage = outputs.packages."${pkgs.system}".pinentry-selector;
          # sshKeys = [
          #   "C817E333BF88F16EA0F7ADE27BDCCC16AD25E5A6"
          # ];
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
