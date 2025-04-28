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
        '';
        config = ''
          #|
              Kanata

              CapsLock tap to Esc
              CapsLock hold to Ctrl
          |#
          ;; default keyboard layout
          (defsrc
              caps  ;; type → esc, hold caps → ctrl
              esc  ;; type esc → caps, hold esc → esc
          )

          (deflayer default
              @cac
              @esc-behavior
          )

          (defalias
              cac (tap-hold 190 190 esc lctrl)  ;; hold CapsLock → Esc, press CapsLock → LCtrl
              esc-behavior (tap-hold 190 190 esc caps)  ;; hold Esc → CapsLock, press Esc → Esc
          )
        '';
      };
    };
  };
}
