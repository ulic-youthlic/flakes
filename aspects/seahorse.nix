{ lib, ... }:
{
  den.aspects.seahorse = {
    xdg-mime = lib.genAttrs [
      "application/pgp-keys"
      "application/x-ssh-key"
      "application/pkcs12"
      "application/pkcs12+pem"
      "application/pkcs7-mime"
      "application/pkcs7-mime+pem"
      "application/pkcs8"
      "application/pkcs8+pem"
      "application/pkix-cert"
      "application/pkix-cert+pem"
      "application/pkix-crl"
      "application/pkix-crl+pem"
      "application/x-pem-file"
      "application/x-pem-key"
      "application/x-pkcs12"
      "application/x-pkcs7-certificates"
      "application/x-x509-ca-cert"
      "application/x-x509-user-cert"
      "application/pkcs10"
      "application/pkcs10+pem"
      "application/x-spkac"
      "application/x-spkac+base64"
    ] (_: [ "org.gnome.seahorse.Application.desktop" ]);
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.seahorse ];
    };
  };
}
