{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.virtualisation.virtualbox;
in {
  options = {
    youthlic.virtualisation.virtualbox = {
      enable = lib.mkEnableOption "virtualbox";
      unixName = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.groups."vboxusers".members = [cfg.unixName];
    virtualisation.virtualbox = {
      host = {
        enableKvm = true;
        enableExtensionPack = true;
        enable = true;
        addNetworkInterface = false;
        enableHardening = true;
      };
      guest = {
        vboxsf = true;
        use3rdPartyModules = true;
        seamless = true;
        enable = true;
        dragAndDrop = true;
        clipboard = true;
      };
    };
  };
}
