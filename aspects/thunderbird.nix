{ den, lib, ... }:
{
  den.aspects.thunderbird =
    { user, ... }:
    let
      identity = user.identity or { };
      signingKey = identity.signingKey or null;
      accountData =
        lib.optionalAttrs (identity ? email) {
          ${identity.email.name or "primary"} = {
            primary = true;
          }
          // removeAttrs identity.email [ "name" ];
        }
        // (user.email.accounts or { });
      accounts = lib.mapAttrs (
        _: account:
        lib.recursiveUpdate (
          {
            address = account.address or identity.email.address;
            realName = account.realName or identity.name;
            thunderbird.enable = true;
          }
          // lib.optionalAttrs (account.primary or false) {
            gpg =
              if signingKey == null then
                null
              else
                {
                  key = signingKey;
                  signByDefault = true;
                };
          }
        ) account
      ) accountData;
      withExternalGnupg = lib.any (
        account:
        (account.enable or true) && (account.thunderbird.enable or false) && (account.gpg or null) != null
      ) (lib.attrValues accounts);
    in
    {
      includes = lib.optional withExternalGnupg den.aspects.gpg;
      homeManager =
        { pkgs, ... }:
        {
          accounts.email.accounts = accounts;
          programs.thunderbird = {
            enable = true;
            package = pkgs.thunderbird-latest;
            profiles.default = {
              inherit withExternalGnupg;
              isDefault = true;
            };
          };
        };
    };
}
