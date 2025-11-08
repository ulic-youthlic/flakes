{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.garage;
in {
  options = {
    youthlic.programs.garage = {
      enable = lib.mkEnableOption "garage";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets."garage" = {
    };
    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      environmentFile = config.sops.secrets."garage".path;
      settings = {
        replication_factor = 1;
        db_engine = "sqlite";
        rpc_bind_addr = "[::]:8490";
        use_local_tz = true;
        allow_punycode = true;
        s3_api = {
          s3_region = "garage";
          api_bind_addr = "[::]:8491";
          root_domain = ".s3.youthlic.social";
        };
        s3_web = {
          root_domain = ".youthlic.social";
          bind_addr = "[::]:8494";
        };
        k2v_api = {
          api_bind_addr = "[::]:8493";
        };
        admin = {
          api_bind_addr = "127.0.0.1:8492";
        };
      };
    };
  };
}
