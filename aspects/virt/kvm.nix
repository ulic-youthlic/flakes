{
  # virt-manager connects to the system libvirt daemon by default.
  den.aspects.virt.kvm.homeManager.dconf = {
    settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
