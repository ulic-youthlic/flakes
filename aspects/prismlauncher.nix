{
  den.aspects.prismlauncher = {
    xdg-mime = {
      "application/x-modrinth-modpack+zip" = [ "org.prismlauncher.PrismLauncher.desktop" ];
      "x-scheme-handler/curseforge" = [ "org.prismlauncher.PrismLauncher.desktop" ];
      "x-scheme-handler/prismlauncher" = [ "org.prismlauncher.PrismLauncher.desktop" ];
    };
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.prismlauncher ];
    };
  };
}
