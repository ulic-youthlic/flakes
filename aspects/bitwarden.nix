{
  den.aspects.bitwarden = {
    xdg-mime."x-scheme-handler/bitwarden" = [ "bitwarden.desktop" ];
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.bitwarden-desktop ];
    };
  };
}
