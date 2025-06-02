{
  pkgs,
  config,
  unixName,
  ...
}: {
  imports = [
    ./niri.nix
  ];
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
      awscli.enable = true;
    };
  };

  david = {
    wallpaper.enable = true;
    accounts.email.enable = true;
    programs = {
      chromium.enable = true;
      espanso.enable = true;
      thunderbird.enable = true;
      foot.enable = false;
      mpv.enable = true;
      ghostty.enable = true;
      alacritty.enable = true;
      zed-editor.enable = true;
      firefox.enable = true;
      openssh.enable = true;
      helix.enable = true;
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
    android-tools
  ];
}
