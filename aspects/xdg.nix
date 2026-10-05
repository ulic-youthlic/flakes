{
  den.aspects.xdg.nixos.xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };
    mime =
      let
        browsers = [
          "zen-twilight.desktop"
          "helium.desktop"
        ];
      in
      {
        enable = true;
        defaultApplications = {
          "application/pdf" = [
            "org.gnome.Evince.desktop"
          ];
          "inode/directory" = [
            "org.gnome.Nautilus.desktop"
          ];
          "text/html" = browsers;
          "x-scheme-handler/about" = browsers;
          "x-scheme-handler/ftp" = browsers;
          "x-scheme-handler/http" = browsers;
          "x-scheme-handler/https" = browsers;
          "x-scheme-handler/mailto" = browsers;
          "x-scheme-handler/unknown" = browsers;
          "image/gif" = [
            "swayimg.desktop"
          ];
          "image/jpeg" = [
            "swayimg.desktop"
          ];
          "image/png" = [
            "swayimg.desktop"
          ];
          "image/webp" = [
            "swayimg.desktop"
          ];
        };
      };
  };
}
