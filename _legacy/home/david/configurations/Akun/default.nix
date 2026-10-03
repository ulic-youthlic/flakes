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
    programs =
      let
        email = config.accounts.email.accounts.ulic-youthlic;
        inherit (email) address name;
        signKey = email.gpg.key;
      in
      {
        git = {
          inherit name signKey;
          email = address;
          encrypt-credential = true;
        };
        jujutsu = {
          inherit name signKey;
          email = address;
        };
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
    scrcpy
    ast-grep
    dig
    numbat
    gitoxide
    fd
    viu
    helium
  ];
}
