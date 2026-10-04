{ ... }: {
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "defaults"
                ];
              };
            };
            crypto-swap = {
              size = "32G";
              content = {
                type = "luks";
                name = "crypto-swap";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
                initrdUnlock = true;
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--hash sha512"
                  "--iter-time 5000"
                  "--pbkdf argon2id"
                  "--key-size 256"
                  "--use-random"
                ];
                extraOpenArgs = [
                  "--timeout 10"
                ];
              };
            };
            crypto1 = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypto1";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                initrdUnlock = true;
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--hash sha512"
                  "--iter-time 5000"
                  "--pbkdf argon2id"
                  "--key-size 256"
                  "--use-random"
                ];
                extraOpenArgs = [
                  "--timeout 10"
                ];
              };
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            crypto2 = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypto2";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                initrdUnlock = true;
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--hash sha512"
                  "--iter-time 5000"
                  "--pbkdf argon2id"
                  "--key-size 256"
                  "--use-random"
                ];
                extraOpenArgs = [
                  "--timeout 10"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-d single"
                    "/dev/mapper/crypto1"
                  ];
                  # Only @root and @home are snapshotted/backed up by btrbk (see ./_filesystem.nix).
                  # Everything else lives in its own subvolume so it is excluded from those snapshots.
                  subvolumes =
                    let
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      subvol = mountpoint: { inherit mountpoint mountOptions; };
                    in
                    {
                      "@root" = subvol "/";
                      "@home" = subvol "/home";
                      "@nix" = subvol "/nix";
                      "@gnu" = subvol "/gnu";
                      "@log" = subvol "/var/log";
                      "@tmp" = subvol "/tmp";
                      # nodatacow is set with `chattr +C` on the subvolume root, not as a mount option
                      "@torrents" = subvol "/var/lib/rqbit";
                      "@cache" = subvol "/home/david/.cache";
                      "@downloads" = subvol "/home/david/dls";
                      "@steam" = subvol "/home/david/.local/share/Steam";
                      "@prismlauncher" = subvol "/home/david/.local/share/PrismLauncher";
                      "@bottles" = subvol "/home/david/.local/share/bottles";
                      # btrbk snapshot_dir, reached through /mnt/btr_pool
                      "@snapshots" = { };
                    };
                };
              };
            };
          };
        };
      };
    };
  };
}
