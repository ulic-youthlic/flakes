{ lib, ... }:
{
  den.aspects.evince.xdg-mime = lib.genAttrs [
    "application/pdf"
    "application/x-bzpdf"
    "application/x-gzpdf"
    "application/x-xzpdf"
    "application/x-ext-pdf"
    "application/postscript"
    "application/x-bzpostscript"
    "application/x-gzpostscript"
    "application/x-ext-eps"
    "application/x-ext-ps"
    "image/x-eps"
    "image/x-bzeps"
    "image/x-gzeps"
    "application/x-dvi"
    "application/x-bzdvi"
    "application/x-gzdvi"
    "application/x-ext-dvi"
    "image/vnd.djvu"
    "application/x-ext-djv"
    "application/x-ext-djvu"
    "application/oxps"
    "application/vnd.ms-xpsdocument"
    "application/illustrator"
    "application/vnd.comicbook-rar"
    "application/vnd.comicbook+zip"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "application/x-ext-cb7"
    "application/x-ext-cbr"
    "application/x-ext-cbt"
    "application/x-ext-cbz"
  ] (_: [ "org.gnome.Evince.desktop" ]);

  den.aspects.evince.nixos = {
    programs.evince.enable = true;
  };
}
