{
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs.config.cudaSupport = true;
  services = {
    hardware.bolt.enable = true;
    fstrim.enable = true;
    input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
  };
  nix = {
    settings = {
      system-features = [ "gccarch-alderlake" ];
    };
  };
  hardware = {
    openrazer = {
      enable = true;
      users = [ "david" ];
    };
    graphics.package = pkgs.mesa_git;
    intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      prime = {
        reverseSync.enable = lib.mkDefault true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
    kernelModules = [
      "ddcci"
      "ddcci-backlight"
      "i2c-dev"
    ];
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
        "x86_64-windows"
        "wasm64-wasi"
      ];
    };
  };
  systemd.services."ddcci@" = {
    description = "ddcci handler";
    after = [ "graphical.target" ];
    before = [ "shutdown.target" ];
    conflicts = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          script = pkgs.writeShellApplication {
            name = "ddcci-handler";
            runtimeInputs = with pkgs; [
              coreutils
              ddcutil
            ];
            text = ''
              echo Trying to attach ddcci to "$1"
              success=0
              i=0
              id=$(echo "$1" | cut -d "-" -f 2)
              while ((success < 1)) && ((i++ < 5)); do
                if ddcutil getvcp 10 -b "$id"; then
                  if echo ddcci 0x37 > "/sys/bus/i2c/devices/$1/new_device"; then
                    success=1
                    echo ddcci attached to "$1"
                  fi
                fi
                echo "Try $i"
                sleep 1;
              done
            '';
          };
        in
        "${lib.getExe' script "ddcci-handler"} %i";
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="NVIDIA i2c adapter*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
  '';
}
