{
  pkgs,
  lib,
  config,
  ...
}:
{
  services = {
    tlp = {
      pd.enable = true;
      settings = {
        TLP_AUTO_SWITCH = 2; # automatic AC/battery switch, but keep a profile you pick by hand
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "quiet"; # your firmware calls power saving "quiet"
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
        # soft-block wifi on boot; unblock manually with `rfkill unblock wifi`
        DEVICES_TO_DISABLE_ON_STARTUP = "wifi";
        RESTORE_DEVICE_STATE_ON_STARTUP = 0;
      };
    };
    hardware.bolt.enable = true;
    fstrim.enable = true;
    input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
    xserver.videoDrivers = [
      "nvidia"
      "modesetting"
    ];
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
    graphics.package = pkgs.mesa;
    intelgpu = {
      vaapiDriver = "intel-media-driver";
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      modesetting.enable = true;
      open = true;
      prime = {
        reverseSync.enable = lib.mkDefault false;
        offload.enable = lib.mkDefault true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      powerManagement = {
        enable = true;
        finegrained = true;
        kernelSuspendNotifier = true;
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
        "wasm64-wasip1"
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
      ExecStart = "${lib.getExe pkgs.ddcci-handler} %i";
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="NVIDIA i2c adapter*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
  '';
}
