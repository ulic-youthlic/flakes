{ config, lib, ... }:
let
  cfg = config.youthlic.programs.fuzzel;
in
{
  options = {
    youthlic.programs.fuzzel = {
      enable = lib.mkEnableOption "fuzzel";
    };
  };
  config = {
    programs.fuzzel = lib.mkIf cfg.enable {
      enable = true;
      settings = {
        main = {
          font = "LXGW WenKai:size=11";
          prompt = "'λ '";
          dpi-aware = true;
        };
        colors = {
          background = "282a36dd";
          text = "f8f8f2ff";
          match = "8be9fdff";
          selection-match = "8be9fdff";
          selection = "44475add";
          selection-text = "f8f8f2ff";
          border = "bd93f9ff";
        };
      };
    };
  };
}
