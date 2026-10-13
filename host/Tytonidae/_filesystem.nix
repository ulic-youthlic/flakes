{
  pkgs,
  ...
}:
let
  backupPartLabel = "tytonidae-backup";
  backupMapperName = "tytonidae-backup";
  backupMountPoint = "/mnt/backup";
in
{
  # Top-level (subvolid=5) view of the pool, needed by btrbk to reach @root/@home/@snapshots.
  fileSystems."/mnt/btr_pool" = {
    device = "/dev/mapper/crypto2";
    fsType = "btrfs";
    options = [
      "subvolid=5"
      "compress=zstd"
      "noatime"
      "nosuid"
      "nodev"
    ];
  };

  # /tmp is the @tmp subvolume (see ./_disk-config.nix): big nix builds don't eat RAM,
  # and it is emptied on every boot like a tmpfs would be.
  boot.tmp.cleanOnBoot = true;

  # Compressed RAM cache in front of the encrypted swap partition. Keeps hibernation working,
  # unlike zram. Pinned here so it does not depend on the kernel's defaults.
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=20"
    "zswap.shrinker_enabled=1"
  ];

  # Data is `single`, so scrub can only detect (not repair) data corruption; the backup is the fix.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # No timer and no local snapshot history: `sudo btrbk-backup` snapshots @root/@home, sends them
  # to the backup disk and keeps only the latest snapshot locally, as the parent for the next
  # incremental send.
  services.btrbk.instances.btrbk = {
    onCalendar = null;
    settings = {
      timestamp_format = "long";
      snapshot_create = "ondemand";
      snapshot_preserve_min = "latest";
      snapshot_preserve = "no";
      target_preserve_min = "no";
      target_preserve = "14d 8w 12m";
      volume."/mnt/btr_pool" = {
        snapshot_dir = "@snapshots";
        target = "${backupMountPoint}/Tytonidae";
        subvolume = {
          "@root" = { };
          "@home" = { };
        };
      };
    };
  };

  systemd.tmpfiles.rules = [ "d ${backupMountPoint} 0755 root root -" ];

  environment.systemPackages = [
    pkgs.e2fsprogs
    (pkgs.btrbk-backup.override {
      inherit backupPartLabel backupMapperName backupMountPoint;
    })
  ];
}
