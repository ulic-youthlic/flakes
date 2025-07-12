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
  imports = with lib; youthlic.loadImports ./.;
  options = {
    youthlic.gui = {
      enabled = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "cosmic"
            "niri"
            "kde"
          ]
        );
        default = null;
        example = "cosmic";
      };
    };
  };
  config = lib.mkIf (cfg.enabled != null) {
    environment.systemPackages = with pkgs; [
      fontconfig
    ];
    programs.firefox.enable = true;

    fonts = {
      enableDefaultPackages = false;
      packages = with pkgs; [
        maple-mono.NF-CN
        noto-fonts-emoji-blob-bin
        source-han-serif
        source-han-sans
        libertinus
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts
      ];
      fontconfig.defaultFonts = {
        serif = [
          "Libertinus Serif"
          "Source Han Serif"
          "Noto Serif CJK SC"
        ];
        sansSerif = [
          "Source Han Sans"
          "Noto Sans CJK SC"
        ];
        monospace = [
          "Maple Mono NF CN"
          "Noto Sans Mono SC"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
