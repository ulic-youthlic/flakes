{
  # Include per user: the user joins the libvirtd and kvm groups, and
  # virt-manager connects to the system libvirt daemon by default.
  den.aspects.kvm = {
    nixos =
      { pkgs, user, ... }:
      {
        environment.systemPackages = with pkgs; [
          quickemu
        ];
        programs.virt-manager = {
          enable = true;
        };
        users.groups.libvirtd.members = [ user.userName ];
        users.groups.kvm.members = [ user.userName ];
        virtualisation = {
          libvirtd = {
            enable = true;
            qemu = {
              runAsRoot = true;
              swtpm.enable = true;
              vhostUserPackages = with pkgs; [ virtiofsd ];
            };
          };
          spiceUSBRedirection = {
            enable = true;
          };
        };
      };
    homeManager.dconf = {
      settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };
    };
  };
}
