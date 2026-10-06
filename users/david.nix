{ den, ... }:
{
  den.users.david = {
    identity = {
      name = "ulic-youthlic";
      email = {
        name = "ulic-youthlic";
        address = "ulic.youthlic@gmail.com";
        aliases = [ "ulic.youthlic+nixpkgs@gmail.com" ];
        flavor = "gmail.com";
        realName = "youthlic";
      };
      signingKey = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
    };
    email.accounts = {
      youthlic146 = {
        address = "youthlic146@gmail.com";
        flavor = "gmail.com";
        realName = "youthlic";
      };
      moqixianli = {
        address = "moqixianli@gmail.com";
        flavor = "gmail.com";
        realName = "youthlic";
      };
      youthlic = {
        address = "youthlic@outlook.com";
        flavor = "outlook.office365.com";
        realName = "youthlic";
      };
      Showoff6558 = {
        address = "Showoff6558@outlook.com";
        flavor = "outlook.office365.com";
        realName = "Showoff6558";
      };
    };
    git.sops = {
      secret = "git-credential";
      path = "/home/david/.config/sops-nix/secrets/git-credential";
    };
    awscli.sops = {
      secret = "awscli";
      path = "/home/david/.config/sops-nix/secrets/awscli";
    };
    openssh = {
      settings."github.com".AddKeysToAgent = "yes";
      sops = {
        keys = {
          tytonidae = {
            secret = "ssh-private-key/tytonidae";
            path = "/home/david/.ssh/id_ed25519_tytonidae";
          };
          akun = {
            secret = "ssh-private-key/akun";
            path = "/home/david/.ssh/id_ed25519_akun";
          };
          cape = {
            secret = "ssh-private-key/cape";
            path = "/home/david/.ssh/id_ed25519_cape";
          };
          deploy = {
            secret = "ssh-private-key/deploy";
            path = "/home/david/.ssh/id_ed25519_deploy";
          };
        };
        config = {
          secret = "ssh-config";
          path = "/home/david/.config/sops-nix/secrets/ssh-config";
          format = "yaml";
          sopsFile = ../secrets/ssh-config.yaml;
        };
      };
    };
    radicle = {
      alias = "youthlic";
      uri = {
        rad.browser = {
          enable = true;
          preferredNode = "iris.radicle.xyz";
        };
        web-rad = {
          browser = "zen-twilight.desktop";
          enable = true;
        };
      };
    };
  };

  den.aspects.david = {
    includes = with den.aspects; [
      david.alacritty
      david.cursor
      ghostty
      david.helix
      david.mpv
      openssh.client
      david.wallpaper
      david.zed
      david.zen-browser
      git
      gpg
      jujutsu
      thunderbird
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
