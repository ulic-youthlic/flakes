{
  lib,
  config,
  options,
  ...
}: let
  cfg = config.youthlic.programs.guix;
in {
  options = {
    youthlic.programs.guix = {
      enable = lib.mkEnableOption "guix";
    };
  };
  config = lib.mkIf cfg.enable {
    services.guix = {
      enable = true;
      gc = {
        enable = true;
        dates = "weekly";
      };
      substituters.urls =
        [
          "https://mirror.sjtu.edu.cn/guix/"
        ]
        ++ options.services.guix.substituters.urls.default;
    };
  };
}
