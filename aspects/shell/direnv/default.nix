{
  den.aspects.shell.direnv.homeManager = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    xdg.configFile."direnvrc" = {
      target = "direnv/direnvrc";
      source = ./direnvrc.sh;
    };
  };
}
