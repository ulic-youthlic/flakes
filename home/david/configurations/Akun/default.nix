{
  pkgs,
  lib,
  unixName,
  config,
  ...
}:
{
  imports = lib.youthlic.loadImports ./.;
  youthlic = {
    xdg-dirs.enable = true;
    programs =
      let
        email = config.accounts.email.accounts.ulic-youthlic;
        inherit (email) address name;
        signKey = email.gpg.key;
      in
      {
        gpg.enable = true;
        git = {
          inherit name signKey;
          email = address;
          encrypt-credential = true;
        };
        fish.enable = true;
        bash.enable = true;
        jujutsu = {
          enable = true;
          inherit name signKey;
          email = address;
        };
        starship.enable = true;
        sops.enable = true;
        atuin.enable = true;
      };
  };

  david = {
    wallpaper.enable = true;
    accounts.email.enable = true;
    programs = {
      chromium.enable = true;
      thunderbird.enable = true;
      mpv.enable = true;
      ghostty.enable = true;
      zed-editor.enable = true;
      zen-browser.enable = true;
      helix.enable = true;
      openssh.enable = true;
      alacritty.enable = true;
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
    fd
    viu
  ];
}
