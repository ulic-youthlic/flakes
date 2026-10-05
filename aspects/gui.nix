{
  den.aspects.gui = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        config = {
          assertions = [
            {
              # niri, kde and cosmic each bring one.
              assertion =
                lib.count lib.id (
                  with config.services.displayManager;
                  [
                    ly.enable
                    sddm.enable
                    cosmic-greeter.enable
                  ]
                ) <= 1;
              message = "Include only one of niri, kde and cosmic.";
            }
          ];

          environment.systemPackages = with pkgs; [
            fontconfig
          ];

          sops.secrets =
            with lib;
            with builtins;
            pipe ../secrets/dummy_font [
              readDir
              attrNames
              (flip genAttrs (name: {
                sopsFile = ../secrets/dummy_font + "/${name}";
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
              noto-fonts-cjk-sans-static
              noto-fonts-cjk-serif-static
              noto-fonts
              nerd-fonts.symbols-only
              iosevka-serif_fixed
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
      };
  };
}
