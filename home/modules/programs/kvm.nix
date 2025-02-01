{ config, lib, ... }:
let
  cfg = config.youthlic.programs.kvm;
in
{
  options = {
    youthlic.programs.kvm = {
      enable = lib.mkEnableOption "kvm";
    };
  };
  config = lib.mkIf cfg.enable {
    dconf = {
      settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };
    };
  };
}
