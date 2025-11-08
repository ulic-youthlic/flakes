{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.minio;
in {
  options = {
    youthlic.programs.minio = {
      enable = lib.mkEnableOption "minio";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets."minio" = {
    };
    services.minio = {
      enable = true;
      listenAddress = ":8487";
      consoleAddress = ":8488";
      rootCredentialsFile = "${config.sops.secrets.minio.path}";
    };
  };
}
