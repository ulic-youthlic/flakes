{
  den.aspects.helium.xdg-mime = {
    "text/html" = [ "helium.desktop" ];
    "application/xhtml+xml" = [ "helium.desktop" ];
    "x-scheme-handler/about" = [ "helium.desktop" ];
    "x-scheme-handler/ftp" = [ "helium.desktop" ];
    "x-scheme-handler/http" = [ "helium.desktop" ];
    "x-scheme-handler/https" = [ "helium.desktop" ];
    "x-scheme-handler/unknown" = [ "helium.desktop" ];
  };

  den.aspects.helium.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.helium ];
    };
}
