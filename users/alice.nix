{ den, ... }:
{
  den.aspects.alice = {
    includes = with den.aspects; [
      dev.git
      dev.gpg
      home.xdg-dirs
      shell.atuin
      shell.bash
      shell.direnv
      shell.fish
      shell.starship
      tty.cli-tools
    ];
    nixos =
      { lib, pkgs, ... }:
      {
        users.users.alice = {
          initialHashedPassword = "$y$j9T$eS5zCi4W.4IPpf3P8Tb/o1$xhumXY1.PJKmTguNi/zlljLbLemNGiubWoUEc878S36";
          isNormalUser = true;
          description = "alice";
          extraGroups = [
            "networkmanager"
            "libvirtd"
            "wheel"
            "video"
          ];
          shell = pkgs.fish;
        };
        programs.fish.enable = lib.mkDefault true;
      };
    homeManager = {
      youthlic.programs.git = {
        email = "ulic.youthlic@gmail.com";
        name = "ulic-youthlic";
        encrypt-credential = false;
      };
      programs.ssh = {
        enable = true;
        extraOptionOverrides = {
          HostKeyAlgorithms = "ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256";
          KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256";
          MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
          Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
        };
        enableDefaultConfig = false;
        settings = {
          "github.com" = {
            HostName = "ssh.github.com";
            Port = 443;
            User = "git";
          };
        };
      };
    };
  };
}
