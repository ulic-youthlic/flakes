{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.kvm;
in {
  options = {
    youthlic.programs.kvm = {
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
      };
      spiceUSBRedirection = {
        enable = true;
      };
    };
  };
}
