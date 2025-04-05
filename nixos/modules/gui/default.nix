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
  imports = [
    ./niri.nix
    ./cosmic.nix
    ./kde.nix
  ];
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
        nerd-fonts.fira-code
        maple-mono.NF-CN
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        lxgw-wenkai
        source-sans
        source-serif
        source-han-serif
        source-han-sans
      ];
      fontconfig.defaultFonts = {
        serif = [
          "LXGW WenKai"
          "Source Han Serif SC"
          "Noto Serif CJK SC"
          "Source Serif 4"
          "Noto Serif"
        ];
        sansSerif = [
          "Source Han Sans SC"
          "Noto Sans CJK SC"
          "Source Sans 3"
          "Noto Sans"
        ];
        monospace = [
          "Maple Mono NF CN"
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
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
