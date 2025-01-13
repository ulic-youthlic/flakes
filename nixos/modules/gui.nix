{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.gui;
in
{
  options = {
    youthlic.gui = {
      enabled = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "cosmic"
            "niri"
          ]
        );
        default = null;
        example = "cosmic";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.enabled == "cosmic") {
      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      services.xserver = {
        display = 0;
        enable = true;
        xkb = {
          layout = "cn";
          variant = "";
        };
      };

      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    })
    (lib.mkIf (cfg.enabled == "niri") {
      services.displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositorCommand = "niri";
        };
      };
      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
    })
    (lib.mkIf (cfg.enabled != null) {
      environment.systemPackages = with pkgs; [
        fontconfig
      ];
      programs.firefox.enable = true;

      fonts = {
        enableDefaultPackages = false;
        packages = with pkgs; [
          nerd-fonts.fira-code
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-emoji
          lxgw-wenkai
        ];
        fontconfig.defaultFonts = pkgs.lib.mkForce {
          serif = [
            "LXGW WenKai"
            "Noto Serif CJK SC"
            "Noto Serif"
          ];
          sansSerif = [
            "Noto Serif CJK SC"
            "Noto Serif"
          ];
          monospace = [
            "FiraCode Nerd Font"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };
    })
  ];
}
