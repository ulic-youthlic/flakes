{ den, ... }:
{
  den.users.david = {
    identity = {
      name = "ulic-youthlic";
      email = "ulic.youthlic@gmail.com";
      signingKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
    };
    git.sops = {
      secret = "git-credential";
      path = "/home/david/.config/sops-nix/secrets/git-credential";
    };
    awscli.sops = {
      secret = "awscli";
      path = "/home/david/.config/sops-nix/secrets/awscli";
    };
  };

  den.aspects.david = {
    includes = with den.aspects; [
      david.alacritty
      david.cursor
      david.email
      david.ghostty
      david.helix
      david.mpv
      david.openssh
      david.thunderbird
      david.wallpaper
      david.zed
      david.zen-browser
      git
      gpg
      jujutsu
      xdg-dirs
      atuin
      bash
      direnv
      eza
      fish
      fzf
      starship
      yazi
      zoxide
      cli-tools
    ];
    nixos =
      { lib, pkgs, ... }:
      {
        users.users.david = {
          initialHashedPassword = "$y$j9T$eS5zCi4W.4IPpf3P8Tb/o1$xhumXY1.PJKmTguNi/zlljLbLemNGiubWoUEc878S36";
          isNormalUser = true;
          description = "david";
          extraGroups = [
            "networkmanager"
            "libvirtd"
            "wheel"
            "video"
            "input"
          ];
          shell = pkgs.fish;
        };
        programs.fish.enable = lib.mkDefault true;
      };
    homeManager =
      { pkgs, ... }:
      {
        services.mpris-proxy.enable = true;
        home.packages = with pkgs; [
          tealdeer
          qq
          scrcpy
          gitoxide
          helium
        ];
      };
  };
}
