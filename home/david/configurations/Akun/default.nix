{
  pkgs,
  unixName,
  config,
  rootPath,
  ...
}: {
  imports = [
    ./niri.nix
  ];
  youthlic = {
    xdg-dirs.enable = true;
    programs = let
      email = config.accounts.email.accounts.ulic-youthlic;
      inherit (email) address name;
      signKey = email.gpg.key;
    in {
      firefox.enable = true;
      fuzzel.enable = true;
      helix.enable = true;
      gpg.enable = true;
      git = {
        inherit name signKey;
        email = address;
        encrypt-credential = true;
      };
      zed-editor.enable = true;
      fish.enable = true;
      bash.enable = true;
      jujutsu = {
        enable = true;
        inherit name signKey;
        email = address;
      };
      ghostty.enable = true;
      starship.enable = true;
      sops.enable = true;
      mpv.enable = true;
      atuin.enable = true;
      obs.enable = true;
      chromium.enable = true;
      thunderbird.enable = true;
      # espanso.enable = true;
    };
  };

  david = {
    wallpaper.enable = true;
    accounts.email.enable = true;
    programs = {
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
  ];
}
