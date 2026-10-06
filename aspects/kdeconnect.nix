{
  den.aspects.kdeconnect.xdg-mime = {
    "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    "x-scheme-handler/sms" = [ "org.kde.kdeconnect.handler.desktop" ];
  };

  den.aspects.kdeconnect.nixos.programs.kdeconnect = {
    enable = true;
  };
}
