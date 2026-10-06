{
  den.aspects.kdenlive = {
    xdg-mime = {
      "application/x-kdenlive" = [ "org.kde.kdenlive.desktop" ];
      "application/vnd.mlt+xml" = [ "org.kde.kdenlive.desktop" ];
    };
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.kdePackages.kdenlive ];
    };
  };
}
