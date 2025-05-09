{...}: {
  imports = [
    ./openssh.nix
    ./niri
    ./wluma
    ./xwayland-satellite.nix
    ./fcitx5-reload.nix
  ];
}
