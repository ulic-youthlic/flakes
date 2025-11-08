{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.virtualisation.kvm;
in {
  options = {
    youthlic.virtualisation.kvm = {
      enable = lib.mkEnableOption "kvm";
      unixName = lib.mkOption {
        type = lib.types.str;
        example = "david";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      quickemu
    ];
    programs.virt-manager = {
      enable = true;
    };
    users.groups.libvirtd.members = [cfg.unixName];
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [virtiofsd];
      };
      spiceUSBRedirection = {
        enable = true;
      };
    };
  };
}
