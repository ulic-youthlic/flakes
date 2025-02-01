{
  rootPath,
  config,
  lib,
  ...
}:
let
  cfg = config.david.programs.openssh;
in
{
  options = {
    david.programs.openssh = {
      enable = lib.mkEnableOption "openssh";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ssh = {
        enable = true;
        hashKnownHosts = true;
        extraOptionOverrides = {
          HostKeyAlgorithms = "ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256";
          KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256";
          MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
          Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
        };
        matchBlocks = {
          "github.com" = {
            hostname = "ssh.github.com";
            port = 443;
            user = "git";
            extraOptions = {
              AddKeysToAgent = "yes";
            };
          };
        };
      };

    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.sops.enable) {
      programs.ssh.includes = [ config.sops.secrets.ssh-config.path ];
      sops.secrets = {
        "ssh-private-key/tytonidae" = {
          mode = "0600";
          path = "${config.home.homeDirectory}/.ssh/id_ed25519_tytonidae";
        };
        "ssh-private-key/akun" = {
          mode = "0600";
          path = "${config.home.homeDirectory}/.ssh/id_ed25519_akun";
        };
        "ssh-private-key/cape" = {
          mode = "0600";
          path = "${config.home.homeDirectory}/.ssh/id_ed25519_cape";
        };
        "ssh-private-key/deploy" = {
          mode = "0600";
          path = "${config.home.homeDirectory}/.ssh/id_ed25519_deploy";
        };
        "ssh-config" = {
          mode = "0400";
          format = "yaml";
          sopsFile = rootPath + "/secrets/ssh-config.yaml";
        };
      };
    })
  ];
}
