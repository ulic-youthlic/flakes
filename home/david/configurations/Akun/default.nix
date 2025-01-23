{
  pkgs,
  unixName,
  config,
  rootPath,
  ...
}:
{
  youthlic.programs = {
    firefox.enable = true;
    fuzzel.enable = true;
    helix.enable = true;
    gpg.enable = true;
    git = {
      email = "ulic.youthlic@gmail.com";
      name = "ulic-youthlic";
      signKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
      encrypt-credential = true;
    };
    fish.enable = true;
    bash.enable = true;
    ghostty.enable = true;
    starship.enable = true;
    sops.enable = true;
    mpv.enable = true;
    atuin.enable = true;
  };

  david = {
    wallpaper.enable = true;
  };

  xdg.userDirs = {
    enable = true;
    download = "${config.home.homeDirectory}/dls";
    documents = "${config.home.homeDirectory}/doc";
    music = "${config.home.homeDirectory}/mus";
    pictures = "${config.home.homeDirectory}/pic";
    videos = "${config.home.homeDirectory}/vid";
    templates = "${config.home.homeDirectory}/tpl";
    publicShare = "${config.home.homeDirectory}/pub";
    desktop = "${config.home.homeDirectory}/dsk";
    createDirectories = true;
  };
  home.username = "${unixName}";
  home.homeDirectory = "/home/${unixName}";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-source-record
      input-overlay
    ];
  };

  home.packages = with pkgs; [
    tealdeer
    ripgrep
    fzf
    file
    which
    gnused
    gnutar
    bat
    gawk
    zstd
    tree
    ouch
    dust
    duf
    doggo
    qq
    telegram-desktop
    ghostty
    scrcpy
    ast-grep
    lazygit
    dig
    fend
    gitoxide
    kdePackages.kdenlive
    fd
    viu
    just
  ];

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
    includes = [ config.sops.secrets.ssh-config.path ];
  };
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-wayland-ime=true"
      "--enable-features=UseOzonePlatform"
    ];
  };
  sops.secrets = {
    "ssh-private-key/tytonidae" = {
      mode = "0600";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519_tytonidae";
    };
    "ssh-private-key/akun" = {
      mode = "0600";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519_akun";
    };
    "ssh-config" = {
      mode = "0400";
      format = "yaml";
      sopsFile = rootPath + "/secrets/ssh-config.yaml";
    };
  };
}
