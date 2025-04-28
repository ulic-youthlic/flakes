{
  pkgs,
  unixName,
  config,
  rootPath,
  ...
}: {
  youthlic = {
    xdg-dirs.enable = true;
    programs = {
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
      zed-editor.enable = true;
      fish.enable = true;
      bash.enable = true;
      jujutsu = {
        enable = true;
        email = "ulic.youthlic@gmail.com";
        name = "ulic-youthlic";
        signKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
      };
      ghostty.enable = true;
      starship.enable = true;
      sops.enable = true;
      mpv.enable = true;
      atuin.enable = true;
      obs.enable = true;
      chromium.enable = true;
      # espanso.enable = true;
    };
  };

  david = {
    wallpaper.enable = true;
    programs = {
      openssh.enable = true;
      niri.enable = true;
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
