{
  lib,
  config,
  ...
}:
let
  cfg = config.david.programs.radicle;
in
{
  options = {
    david.programs.radicle = {
      enable = lib.mkEnableOption "radicle";
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.programs.radicle.enable = true;
    programs.radicle.uri = {
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
}
