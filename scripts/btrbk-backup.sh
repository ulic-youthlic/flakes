# shellcheck shell=bash
# Body only: buildBashTool wraps this with a shebang, `set -euo pipefail` and a
# PATH built from the overlay's runtimeInputs.
#
# The @...@ tokens are substituted at build time from the calling host, which
# owns the partition label, mapper name and mount point.

if [ "$(id -u)" -ne 0 ]; then
  echo "run as root: sudo btrbk-backup [--scrub]" >&2
  exit 1
fi

dev=/dev/disk/by-partlabel/@backupPartLabel@
if [ ! -e "$dev" ]; then
  echo "backup disk ($dev) is not plugged in" >&2
  exit 1
fi

opened=0
mounted=0
cleanup() {
  if [ "$mounted" = 1 ]; then umount @backupMountPoint@; fi
  if [ "$opened" = 1 ]; then cryptsetup close @backupMapperName@; fi
}
trap cleanup EXIT

if [ ! -e /dev/mapper/@backupMapperName@ ]; then
  # FIDO2 token (CanoKey) if enrolled, falls back to the passphrase after 10s
  systemd-cryptsetup attach @backupMapperName@ "$dev" - fido2-device=auto,token-timeout=10
  opened=1
fi
if ! mountpoint -q @backupMountPoint@; then
  mount -o noatime,compress=zstd /dev/mapper/@backupMapperName@ @backupMountPoint@
  mounted=1
fi

btrbk -c /etc/btrbk/btrbk.conf run --progress
if [ "${1:-}" = "--scrub" ]; then
  btrfs scrub start -B @backupMountPoint@
fi
sync
