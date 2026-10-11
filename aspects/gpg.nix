{
  den.aspects.gpg.homeManager =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      # Hosts without a graphical session only need the terminal pinentry.
      graphical = osConfig.services.graphical-desktop.enable;
    in
    {
      # pinentry-gnome3 uses GCR's D-Bus prompt service.
      home.packages = lib.optional (pkgs.stdenv.hostPlatform.isLinux && graphical) pkgs.gcr_3;

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry.package =
          if pkgs.stdenv.hostPlatform.isDarwin then
            pkgs.pinentry_mac
          else if graphical then
            pkgs.pinentry-selector
          else
            pkgs.pinentry-tty;
      };
      programs.gpg = {
        enable = true;
        mutableKeys = true;
        mutableTrust = true;
        publicKeys = [
          {
            source = ../assets/gpg/public-key.txt;
            trust = "ultimate";
          }
        ];
      };
    };
}
