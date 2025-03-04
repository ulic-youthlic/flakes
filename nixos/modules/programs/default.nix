{ config, lib, ... }:
{
  imports = [
    ./transfer-sh.nix
    ./rustypaste
    ./mautrix-telegram.nix
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
    ./conduwuit.nix
    ./nix-ld.nix
    ./juicity
    ./miniflux.nix
  ];
}
