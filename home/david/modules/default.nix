{pkgs, ...}: {
  imports = [
    ./wallpaper.nix
    ./programs
    ./emails.nix
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
