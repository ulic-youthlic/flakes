{ config, lib, ... }:
let
  cfg = config.youthlic.programs.foot;
in
{
  options = {
    youthlic.programs.foot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = ''
          whether use foot terminal
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = builtins.fromINI (builtins.readFile ./foot.ini);
    };
  };
}
