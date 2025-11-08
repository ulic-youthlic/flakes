{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.kanata;
in {
  options = {
    youthlic.programs.kanata = {
      enable = lib.mkEnableOption "kanata";
    };
  };
  config = lib.mkIf cfg.enable {
    boot.kernelModules = ["uinput"];
    hardware.uinput.enable = true;
    services.kanata = {
      enable = true;
      package = pkgs.kanata-with-cmd;
      keyboards.default = {
        extraDefCfg = ''
          process-unmapped-keys no
          concurrent-tap-hold yes
        '';
        config = builtins.readFile ./kanata.lisp;
      };
    };
  };
}
