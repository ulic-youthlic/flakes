{
  config,
  lib,
  pkgs,
  rootPath,
  ...
}: let
  cfg = config.youthlic.gui;
in {
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
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;
    };

    sops.secrets = with lib;
    with builtins;
      pipe (rootPath + "/secrets/dummy_font") [
        readDir
        attrNames
        (flip genAttrs (name: {
          sopsFile = rootPath + "/secrets/dummy_font/${name}";
          format = "binary";
          path = "/run/fonts/${name}";
          mode = "0444";
        }))
      ];

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
      fontconfig = {
        localConf =
          #xml
          ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
            <dir>/run/fonts</dir>
            </fontconfig>
          '';
        defaultFonts = {
          serif = [
            "Libertinus Serif"
            "Source Han Serif SC"
            "Noto Serif CJK SC"
          ];
          sansSerif = [
            "Source Han Sans SC"
            "Noto Sans CJK SC"
          ];
          monospace = [
            "MonoLisa"
            "Maple Mono NF CN"
            "Noto Sans Mono SC"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
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
