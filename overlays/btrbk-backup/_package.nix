{
  pkgs,
  lib,
  buildBashTool,
  # The three values live in host/Tytonidae/_filesystem.nix, which owns the
  # partition layout; they are baked in here so the script reads as plain bash.
  backupPartLabel ? "tytonidae-backup",
  backupMapperName ? "tytonidae-backup",
  backupMountPoint ? "/mnt/backup",
}:
buildBashTool {
  pname = "btrbk-backup";
  substitutions = {
    inherit backupPartLabel backupMapperName backupMountPoint;
  };
  runtimeInputs = with pkgs; [
    btrbk
    btrfs-progs
    cryptsetup
    util-linux
    systemd
  ];
  meta = {
    description = "Snapshot and send btrfs subvolumes to the encrypted backup disk";
    platforms = lib.platforms.linux;
  };
}
