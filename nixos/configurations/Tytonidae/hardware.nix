{
  pkgs,
  lib,
  config,
  ...
}: {
  virtualisation.libvirtd.hooks.qemu = {
    "dynamic-cpu-isolation" =
      pkgs.writeShellScript "dynamic-cpu-isolation.sh"
      #bash
      ''
        VM_NAME="$1"
        ACTION="$2"

        if [ "$VM_NAME" != "win11" ]; then
          exit 0
        fi

        if [ "$ACTION" == "prepare" ]; then
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- system.slice AllowedCPUs=0-1,12-19
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- user.slice AllowedCPUs=0-1,12-19
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- init.scope AllowedCPUs=0-1,12-19
        elif [ "$ACTION" == "release" ]; then
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- system.slice AllowedCPUs=0-19
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- user.slice AllowedCPUs=0-19
          ${lib.getExe' pkgs.systemd "systemctl"} set-property --runtime -- init.scope AllowedCPUs=0-19
        fi
      '';
  };
  nixpkgs.config.cudaSupport = true;
  services = {
    hardware.bolt.enable = true;
    fstrim.enable = true;
    input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
    # xserver.videoDrivers = ["nvidia"];
  };
  nix = {
    settings = {
      system-features = ["gccarch-alderlake"];
    };
  };
  hardware = {
    openrazer = {
      enable = true;
      users = ["david"];
    };
    graphics.package = pkgs.mesa;
    intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };
    # nvidia = {
    #   # Fix Nvidia API Change, See <https://github.com/NixOS/nixpkgs/issues/467814/>
    #   package = config.boot.kernelPackages.nvidiaPackages.beta;
    #   modesetting.enable = true;
    #   open = true;
    #   prime = {
    #     reverseSync.enable = lib.mkDefault false;
    #     offload.enable = lib.mkDefault true;
    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    #   };
    # };
  };
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ddcci-driver];
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
    kernelModules = [
      "ddcci"
      "ddcci-backlight"
      "i2c-dev"
      "vfio-pci.ids=10de:2520,10de:228e"
    ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2520,10de:228e
      softdep nvidia pre: vfio-pci
      softdep nouveau pre: vfio-pci
      softdep nvidia_drm pre: vfio-pci
      softdep nvidia_modeset pre: vfio-pci
    '';
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
    after = ["graphical.target"];
    before = ["shutdown.target"];
    conflicts = ["shutdown.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
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
      in "${lib.getExe' script "ddcci-handler"} %i";
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="NVIDIA i2c adapter*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
  '';
}
