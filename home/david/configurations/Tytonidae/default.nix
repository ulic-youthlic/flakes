{
  pkgs,
  config,
  rootPath,
  inputs,
  unixName,
  ...
}:
{
  youthlic = {
    xdg-dirs.enable = true;
    programs = {
      zed-editor.enable = true;
      rustypaste-cli.enable = true;
      firefox.enable = true;
      fuzzel.enable = true;
      helix.enable = true;
      gpg.enable = true;
      jujutsu = {
        enable = true;
        email = "ulic.youthlic@gmail.com";
        name = "ulic-youthlic";
        signKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
      };
      git = {
        email = "ulic.youthlic@gmail.com";
        name = "ulic-youthlic";
        signKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
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
    };
  };

  david = {
    wallpaper.enable = true;
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
