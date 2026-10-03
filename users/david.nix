{ den, ... }:
{
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
      dev.git
      dev.gpg
      dev.jujutsu
      home.xdg-dirs
      shell.atuin
      shell.bash
      shell.direnv
      shell.eza
      shell.fish
      shell.fzf
      shell.starship
      shell.yazi
      shell.zoxide
      tty.cli-tools
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
      { config, pkgs, ... }:
      {
        imports = [ ../_legacy/home/david/modules ];
        services.mpris-proxy.enable = true;
        youthlic.programs =
          let
            email = config.accounts.email.accounts.ulic-youthlic;
            inherit (email) name address;
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
