{ den, ... }: {
  den.aspects.incus = {
    includes = with den.aspects; [ nftables ];
    nixos =
      { host, user, ... }:
      {
        virtualisation.incus = {
          enable = true;
          ui.enable = true;
          preseed.config."core.https_address" = host.incus.httpsAddress;
        };
        networking.nftables.enable = true;
        users.groups.incus-admin.members = [ user.userName ];
      };
  };
}
