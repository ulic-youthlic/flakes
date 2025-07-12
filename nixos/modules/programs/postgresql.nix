{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.postgresql;
in
{
  options = {
    youthlic.programs.postgresql = {
      enable = lib.mkEnableOption "postgresql";
      database = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "forgejo";
      };
      auth_method = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "peer";
      };
      version = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "17";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # default socket: /var/lib/postgresql
    services.postgresql = {
      enable = true;
      ensureDatabases = [ cfg.database ];
      ensureUsers = [
        {
          name = "${cfg.database}";
          ensureDBOwnership = true;
        }
      ];
      package = pkgs."postgresql_${cfg.version}";
      authentication = ''
        #type database DBuser auth-method
        local sameuser all    ${cfg.auth_method}
      '';
    };
  };
}
