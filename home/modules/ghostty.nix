{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    youthlic.programs.ghostty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        example = false;
        default = true;
        description = ''
          whether enable ghostty
        '';
      };
    };
  };
  config =
    let
      cfg = config.youthlic.programs.ghostty;
    in
    (lib.mkIf cfg.enable {
      programs.ghostty = lib.mkMerge [
        {
          enable = true;
          package = pkgs.ghostty;
          settings = {
            font-family = "FiraCode Nerd Font";
            font-feature = [
              "calt=1"
              "clig=1"
              "liga=1"
              "cv01"
              "cv02"
              "cv06"
              "zero"
              "onum"
              "cv17"
              "ss05"
              "ss03"
              "cv16"
              "cv31"
              "cv29"
              "cv30"
            ];
            font-size = 17;
            theme = "ayu";
            background-opacity = 0.8;
          };
        }
        (lib.mkIf config.youthlic.programs.fish.enable {
          enableFishIntegration = true;
        })
        (lib.mkIf config.youthlic.programs.bash.enable {
          enableBashIntegration = true;
        })
      ];
    });
}
