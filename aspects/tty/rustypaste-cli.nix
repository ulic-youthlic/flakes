{
  den.aspects.tty.rustypaste-cli.homeManager =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.rustypaste-cli ];
      sops = {
        secrets = {
          "rustypaste/auth" = { };
          "rustypaste/delete" = { };
        };
        templates."rustypaste-config.toml" = {
          path = "${config.xdg.configHome}/rustypaste/config.toml";
          content = ''
            [server]
            address = "https://paste.youthlic.social"
            auth_token = "${config.sops.placeholder."rustypaste/auth"}"
            delete_token = "${config.sops.placeholder."rustypaste/delete"}"

            [paste]
            oneshot = false

            [style]
            prettify = true
          '';
        };
      };
    };
}
