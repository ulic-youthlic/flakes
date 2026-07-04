{
  pkgs,
  lib,
  config,
  unixName,
  ...
}: {
  imports = lib.youthlic.loadImports ./.;
  youthlic = {
    xdg-dirs.enable = true;
    programs = let
      email = config.accounts.email.accounts.ulic-youthlic;
      inherit (email) name address;
      signKey = email.gpg.key;
    in {
      rustypaste-cli.enable = true;
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
      starship.enable = true;
      sops.enable = true;
      kvm.enable = true;
      atuin.enable = true;
      ion.enable = true;
      awscli = {
        enable = true;
        url = "http://localhost:8491";
      };
    };
  };

  david = {
    wallpaper.enable = true;
    accounts.email.enable = true;
    programs = {
      spotify.enable = true;
      chromium.enable = true;
      thunderbird.enable = true;
      foot.enable = false;
      mpv.enable = true;
      ghostty.enable = true;
      alacritty.enable = true;
      zed-editor.enable = true;
      zen-browser.enable = true;
      openssh.enable = true;
      helix.enable = true;
      # spacemacs.enable = true;
      radicle.enable = true;
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
    scrcpy
    ast-grep
    dig
    fend
    gitoxide
    kdePackages.kdenlive
    fd
    viu
    android-tools
  ];
}
