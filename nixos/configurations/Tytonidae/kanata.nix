{ lib, ... }: {
  youthlic.programs.kanata.enable = true;
  services = {
    udev.extraRules = ''
      KERNEL=="event*", ATTRS{name}=="kanata-virtual-kbd", SYMLINK+="input/kanata-kbd"
    '';
    kanata.keyboards.default = {
      devices = [
        "/dev/input/by-id/usb-RDR_Crush_80-event-kbd"
      ];
      extraDefCfg = ''
        linux-output-device-name "kanata-virtual-kbd"
      '';
    };
  };
  systemd.services.kanata-default.serviceConfig = {
    PrivateUsers = lib.mkForce false;
    DynamicUser = lib.mkForce false;
  };
}
