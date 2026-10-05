{
  den.aspects.kanata.nixos =
    { pkgs, ... }:
    {
      boot.kernelModules = [ "uinput" ];
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
