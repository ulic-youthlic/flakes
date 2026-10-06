{ lib, ... }:
{
  den.aspects.swayimg.xdg-mime = lib.genAttrs [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heif"
    "image/jpeg"
    "image/jpg"
    "image/jxl"
    "image/pbm"
    "image/pjpeg"
    "image/png"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-exr"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-targa"
    "image/x-tga"
  ] (_: [ "swayimg.desktop" ]);

  den.aspects.swayimg.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.swayimg ];
    };
}
