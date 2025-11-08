{
  config,
  lib,
  ...
}: let
  cfg = config.david.accounts.email;
in {
  options = {
    david.accounts.email = {
      enable = lib.mkEnableOption "emails";
    };
  };
  config = lib.mkIf cfg.enable {
    accounts.email.accounts = {
      "ulic-youthlic" = {
        address = "ulic.youthlic@gmail.com";
        aliases = [
          "ulic.youthlic+nixpkgs@gmail.com"
        ];
        flavor = "gmail.com";
        gpg = {
          signByDefault = true;
          key = "C6FCBD7F49E1CBBABD6661F7FC02063F04331A95";
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
    };
  };
}
