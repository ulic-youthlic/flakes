{ lib, ... }:
{
  den.aspects.nautilus.xdg-mime = lib.genAttrs [
    "inode/directory"
    "application/zip"
    "application/vnd.rar"
    "application/x-7z-compressed"
    "application/x-7z-compressed-tar"
    "application/x-tar"
    "application/x-tarz"
    "application/x-compress"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/gzip"
    "application/x-gzip"
    "application/bzip2"
    "application/x-bzip"
    "application/x-bzip-compressed-tar"
    "application/x-bzip2-compressed-tar"
    "application/x-lha"
    "application/x-lzip"
    "application/x-lzip-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-xar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/zstd"
    "application/x-zstd-compressed-tar"
  ] (_: [ "org.gnome.Nautilus.desktop" ]);

  den.aspects.nautilus.nixos =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;
      programs.dconf.enable = true;
      programs.nautilus-open-any-terminal.enable = true;

      environment = {
        systemPackages = with pkgs; [
          nautilus
          libheif
          libheif.out
        ];
        pathsToLink = [ "/share/thumbnailers" ];
      };
    };
}
