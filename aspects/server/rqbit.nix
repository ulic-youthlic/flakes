{
  den.aspects.server.rqbit.nixos =
    {
      pkgs,
      lib,
      config,
      options,
      host,
      ...
    }:
    let
      cfg = config.youthlic.programs.rqbit;
    in
    {
      options = {
        youthlic.programs.rqbit = {
          ratelimitUpload = lib.mkOption {
            type = lib.types.int;
            description = ''
              Limit upload to mega-bytes-per-second
            '';
          };
          httpHost = options.services.rqbit.httpHost;
        };
      };
      config = {
        services.rqbit = {
          inherit (cfg) httpHost;
          enable = true;
          openFirewall = true;
          httpPort = 9092;
        };
        # The host's users may manage the downloads.
        users.groups.rqbit.members = map (user: user.userName) (lib.attrValues host.users);
        sops.secrets."rqbit.secrets.env" = { };
        systemd.services."rqbit" = {
          serviceConfig = {
            EnvironmentFile = [
              (toString (
                pkgs.writeText "rqbit-env.env" (
                  # env
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
                    ''
                  )
                )
              ))
              config.sops.secrets."rqbit.secrets.env".path
            ];
          };
        };
      };
    };
}
