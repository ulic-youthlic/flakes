{
  den.aspects.david.email.homeManager =
    {
      user,
      ...
    }:
    let
      identity = user.identity;
    in
    {
      config = {
        accounts.email.accounts = {
          "ulic-youthlic" = {
            address = identity.email;
            aliases = [
              "ulic.youthlic+nixpkgs@gmail.com"
            ];
            flavor = "gmail.com";
            gpg =
              if (identity.signingKey or null) == null then
                null
              else
                {
                  signByDefault = true;
                  key = identity.signingKey;
                };
            primary = true;
            thunderbird = {
              enable = true;
            };
            realName = "youthlic";
          };
          "youthlic146" = {
            address = "youthlic146@gmail.com";
            flavor = "gmail.com";
            thunderbird = {
              enable = true;
            };
            realName = "youthlic";
          };
          "moqixianli" = {
            address = "moqixianli@gmail.com";
            flavor = "gmail.com";
            thunderbird = {
              enable = true;
            };
            realName = "youthlic";
          };
          "youthlic" = {
            address = "youthlic@outlook.com";
            flavor = "outlook.office365.com";
            thunderbird = {
              enable = true;
              settings = id: {
                "mail.server.server_${id}.type" = "imap";
                "mail.smtpserver.smtp_${id}.authMethod" = 10; # 10 for OAuth2
                "mail.server.server_${id}.authMethod" = 10;
                "mail.server.server_${id}.socketType" = 3; # 3 for SSL/TLS
              };
            };
            realName = "youthlic";
            imap = {
              host = "outlook.office365.com";
              tls.enable = true;
            };
          };
          "Showoff6558" = {
            address = "Showoff6558@outlook.com";
            flavor = "outlook.office365.com";
            thunderbird = {
              enable = true;
              settings = id: {
                "mail.server.server_${id}.type" = "imap";
                "mail.smtpserver.smtp_${id}.authMethod" = 10; # 10 for OAuth2
                "mail.server.server_${id}.authMethod" = 10;
                "mail.server.server_${id}.socketType" = 3; # 3 for SSL/TLS
              };
            };
            realName = "Showoff6558";
            imap = {
              host = "outlook.office365.com";
              tls.enable = true;
            };
          };
        };
      };
    };
}
