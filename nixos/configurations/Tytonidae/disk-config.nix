{ ... }:
{
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
              size = "512M";
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
            crypto1 = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypto1";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  fallbackToPassword = true;
                  # keyFile = "/dev/disk/by-label/LUKS_DECR";
                  # keyFileSize = 512 * 64;
                  # keyFileOffset = 512 * 192;
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
                  fallbackToPassword = true;
                  # keyFile = "/dev/disk/by-label/LUKS_DECR";
                  # keyFileSize = 512 * 64;
                  # keyFileOffset = 512 * 192;
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
                    "-m dup"
                    "-d raid0"
                    "/dev/mapper/crypto1"
                  ];
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      swap = {
                        swapfile.size = "32G";
                      };
                    };
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
