{
  den.aspects.rqbit.nixos =
    {
      pkgs,
      lib,
      host,
      ...
    }:
    let
      cfg = host.rqbit;
    in
    {
      config = {
        services.rqbit = {
          enable = true;
          openFirewall = true;
          httpPort = 9092;
        };
        # The host's users may manage the downloads.
        users.groups.rqbit.members = map (user: user.userName) (lib.attrValues host.users);
        sops.secrets.${cfg.sops.secret}.path = cfg.sops.path;
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
              cfg.sops.path
            ];
          };
        };
      };
    };
}
