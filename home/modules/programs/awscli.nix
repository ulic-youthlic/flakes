{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.awscli;
in {
  options = {
    youthlic.programs.awscli = {
      enable = lib.mkEnableOption "awscli";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets."awscli" = {};
    programs.awscli = {
      enable = true;
      credentials = {
        default = {
          credential_process = "${lib.getExe' pkgs.uutils-coreutils-noprefix "cat"} ${config.sops.secrets.awscli.path}";
        };
      };
      settings = {
        default = {
          region = "garage";
          endpoint_url = "https://s3.youthlic.social";
        };
      };
    };
  };
}
