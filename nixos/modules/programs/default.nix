{ config, lib, ... }:
{
  imports = [
    ./caddy.nix
    ./dae
    ./forgejo.nix
    ./kanata.nix
    ./kvm.nix
    ./nh.nix
    ./open-webui.nix
    ./openssh.nix
    ./postgresql.nix
    ./steam.nix
    ./tailscale.nix
    ./transmission.nix
  ];
}
