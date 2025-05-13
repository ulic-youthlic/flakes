{config, ...}: {
  sops.secrets."ssh-private-key/radicle/Cape" = {};
  youthlic.programs.radicle = {
    enable = true;
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbQrJNWcWsFncTX4w/hkhz6zPNwHrTjA+6lnq5dmu/s radicle";
    privateKeyFile = config.sops.secrets."ssh-private-key/radicle/Cape".path;
    domain = "seed.youthlic.fun";
  };
}
