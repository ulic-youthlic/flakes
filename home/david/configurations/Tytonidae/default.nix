{
  pkgs,
  config,
  rootPath,
  inputs,
  unixName,
  ...
}: {
  youthlic = {
    xdg-dirs.enable = true;
    programs = let
      email = config.accounts.email.accounts.ulic-youthlic;
      inherit (email) name address;
      signKey = email.gpg.key;
    in {
      zed-editor.enable = true;
      rustypaste-cli.enable = true;
      firefox.enable = true;
      fuzzel.enable = true;
      helix.enable = true;
      gpg.enable = true;
      jujutsu = {
        enable = true;
        inherit name signKey;
        email = address;
      };
      git = {
        inherit name signKey;
        email = address;
        encrypt-credential = true;
      };
      fish.enable = true;
      bash.enable = true;
      ghostty.enable = true;
      foot.enable = false;
      starship.enable = true;
      sops.enable = true;
      mpv.enable = true;
      kvm.enable = true;
      atuin.enable = true;
      thunderbird.enable = true;
      obs.enable = true;
      chromium.enable = true;
      espanso.enable = true;
    };
  };

  david = {
    wallpaper.enable = true;
    accounts.email.enable = true;
    programs = {
      niri.enable = true;
      openssh.enable = true;
    };
  };

  home.username = "${unixName}";
  home.homeDirectory = "/home/${unixName}";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
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
    android-tools
  ];
}
