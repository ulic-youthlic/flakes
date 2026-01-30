{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  cfg = config.youthlic.programs.rqbit;
in {
  options = {
    youthlic.programs.rqbit = {
      enable = lib.mkEnableOption "rqbit";
      unixName = lib.mkOption {
        type = lib.types.str;
      };
      ratelimitUpload = lib.mkOption {
        type = lib.types.int;
        description = ''
          Limit upload to mega-bytes-per-second
        '';
      };
      httpHost = options.services.rqbit.httpHost;
    };
  };
  config = lib.mkIf cfg.enable {
    services.rqbit = {
      inherit (cfg) httpHost;
      enable = true;
      openFirewall = true;
      httpPort = 9092;
    };
    users.groups.rqbit.members = [cfg.unixName];
    systemd.services."rqbit" = {
      serviceConfig = {
        EnvironmentFile = [
          (toString
            (
              pkgs.writeText
              "rqbit-env.env"
              ( # env
                # ''
                #   RQBIT_TRACKERS_FILENAME=${pkgs.trackerslist}/trackers_all.txt
                # ''
                ''
                  RQBIT_TRACKERS_FILENAME=${pkgs.TrackersListCollection}/all.txt
                ''
                + (lib.optionalString (cfg.ratelimitUpload != 0)
                  # env
                  ''
                    RQBIT_RATELIMIT_UPLOAD=${toString (cfg.ratelimitUpload * 1024 * 1024)}
                  '')
              )
            ))
        ];
      };
    };
  };
}
