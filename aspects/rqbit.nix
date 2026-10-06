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
    assert lib.assertMsg (
      builtins.isInt cfg.ratelimitUpload && cfg.ratelimitUpload >= 0
    ) "host.rqbit.ratelimitUpload must be a nonnegative integer in MiB/s (0 omits the limit)";
    {
      services.rqbit = {
        enable = true;
        openFirewall = true;
        httpPort = 9092;
      };
      # The host's users may manage the downloads.
      users.groups.rqbit.members = map (user: user.userName) (lib.attrValues host.users);
      sops.secrets.${cfg.sops.secret}.path = cfg.sops.path;
      systemd.services.rqbit = {
        environment = {
          RQBIT_TRACKERS_FILENAME = "${pkgs.TrackersListCollection}/all.txt";
        }
        // lib.optionalAttrs (cfg.ratelimitUpload > 0) {
          RQBIT_RATELIMIT_UPLOAD = toString (cfg.ratelimitUpload * 1024 * 1024);
        };
        serviceConfig.EnvironmentFile = [ cfg.sops.path ];
      };
    };
}
