{ self, ... }:
{
  den.aspects.dev.gpg.homeManager =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      services.gpg-agent = lib.mkMerge [
        {
          enable = true;
          enableSshSupport = true;
          pinentry = {
            package = self.packages."${pkgs.stdenv.hostPlatform.system}".pinentry-selector;
          };
          # sshKeys = [
          #   "C817E333BF88F16EA0F7ADE27BDCCC16AD25E5A6"
          # ];
        }
        (lib.mkIf config.programs.fish.enable {
          enableFishIntegration = true;
        })
        (lib.mkIf config.programs.bash.enable {
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
