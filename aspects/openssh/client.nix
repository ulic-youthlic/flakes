{ den, lib, ... }:
{
  den.aspects.openssh.client =
    { user, ... }:
    let
      cfg = user.openssh or { };
      sops = cfg.sops or null;
      keys = if sops == null then { } else sops.keys or { };
      configSecret = if sops == null then null else sops.config or null;
    in
    {
      includes =
        lib.optional (keys != { } || configSecret != null) den.aspects.sops
        ++ lib.optional (keys != { }) {
          homeManager.sops.secrets = lib.mapAttrs' (
            _: key: lib.nameValuePair key.secret ({ mode = "0600"; } // removeAttrs key [ "secret" ])
          ) keys;
        }
        ++ lib.optional (configSecret != null) {
          homeManager = {
            programs.ssh.includes = [ configSecret.path ];
            sops.secrets.${configSecret.secret} = {
              mode = "0400";
            }
            // removeAttrs configSecret [ "secret" ];
          };
        };

      homeManager =
        { pkgs, ... }:
        {
          programs.ssh = {
            enable = true;
            package = pkgs.openssh;
            extraOptionOverrides = {
              HostKeyAlgorithms = "ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256";
              KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256";
              MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
              Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
            };
            enableDefaultConfig = false;
            settings = lib.recursiveUpdate {
              "github.com" = {
                HostName = "ssh.github.com";
                Port = 443;
                User = "git";
              };
            } (cfg.settings or { });
          };
        };
    };
}
