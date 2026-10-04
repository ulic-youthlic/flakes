{
  den.aspects.net.juicity.client.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./_service.nix ];
      config = lib.mkMerge [
        {
          users.groups.juicity.members = [ "root" ];
          sops = {
            secrets = {
              "juicity/serverIp" = { };
              "juicity/sni" = { };
              "juicity/certchainSha256" = { };
            };
            templates."juicity-client-config.json" = {
              group = "juicity";
              mode = "0440";
              content = ''
                {
                  "listen": ":7890",
                  "server": "${config.sops.placeholder."juicity/serverIp"}:23182",
                  "uuid": "${config.sops.placeholder."juicity/uuid"}",
                  "password": "${config.sops.placeholder."juicity/password"}",
                  "sni": "${config.sops.placeholder."juicity/sni"}",
                  "allow_insecure": false,
                  "pinned_certchain_sha256": "${config.sops.placeholder."juicity/certchainSha256"}",
                  "log_level": "info"
                }
              '';
            };
          };
          services.juicity.client = {
            enable = true;
            package = pkgs.juicity;
            configFile = "${config.sops.templates."juicity-client-config.json".path}";
            allowedOpenFirewallPorts = [
              7890
            ];
            group = "juicity";
          };
        }
        {
          sops.secrets = {
            "juicity/uuid" = { };
            "juicity/password" = { };
          };
        }
      ];
    };
}
