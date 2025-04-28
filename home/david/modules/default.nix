{pkgs, ...}: {
  imports = [
    ./wallpaper.nix
    ./programs
  ];
  config = {
    services.mpris-proxy.enable = true;
    home.packages = with pkgs; [
      spacer
      devenv
      just
      showmethekey
    ];
  };
}
