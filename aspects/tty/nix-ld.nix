{
  den.aspects.tty.nix-ld.nixos =
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          fuse3
          icu
          nss
          openssl
          curl
          expat
          rustls-libssl
          glib
          nspr
          at-spi2-core
          dbus
          cups
          expat
          libxcb
          libxkbcommon
          alsa-lib
          libgbm
          libx11
          libxext
          cairo
          pango
          systemdLibs
          libxcomposite
          libxdamage
          libxfixes
          libxrandr
        ];
      };
    };
}
