{ config, lib, ... }:
let
  cfg = config.youthlic.programs.direnv;
in
{
  options = {
    youthlic.programs.direnv = {
      enable = lib.mkEnableOption "direnv";
    };
  };
  config = lib.mkIf cfg.enable {
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
