{ den, ... }:
{
  den.aspects.rustypaste-cli =
    { user, ... }:
    let
      cfg = user.rustypaste-cli;
    in
    {
      includes = [ den.aspects.sops ];
      homeManager =
        { config, pkgs, ... }:
        {
          home.packages = [ pkgs.rustypaste-cli ];
          sops = {
            secrets = {
              ${cfg.sops.auth.secret} = { };
              ${cfg.sops.delete.secret} = { };
            };
            templates."rustypaste-config.toml" = {
              path = "${config.xdg.configHome}/rustypaste/config.toml";
              content = ''
                [server]
                address = ${builtins.toJSON cfg.url}
                auth_token = "${config.sops.placeholder.${cfg.sops.auth.secret}}"
                delete_token = "${config.sops.placeholder.${cfg.sops.delete.secret}}"

                [paste]
                oneshot = false

                [style]
                prettify = true
              '';
            };
          };
        };
    };
}
