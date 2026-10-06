{
  den.aspects.gpg.homeManager =
    { lib, pkgs, ... }:
    {
      # pinentry-gnome3 uses GCR's D-Bus prompt service.
      home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.gcr_3;

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry.package =
          if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-selector;
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
