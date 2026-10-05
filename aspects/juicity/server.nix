{
  den.aspects.juicity.server.nixos =
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
              "juicity/certificate" = {
                group = "juicity";
                mode = "0440";
              };
              "juicity/private_key" = {
                group = "juicity";
                mode = "0440";
              };
            };
            templates."juicity-server-config.json" = {
              group = "juicity";
              mode = "0440";
              content = ''
                {
                  "listen": ":23182",
                  "users": {
                    "${config.sops.placeholder."juicity/uuid"}": "${config.sops.placeholder."juicity/password"}"
                  },
                  "certificate": "${config.sops.secrets."juicity/certificate".path}",
                  "private_key": "${config.sops.secrets."juicity/private_key".path}",
                  "log_level": "info"
                }
              '';
            };
          };
          services.juicity.server = {
            enable = true;
            package = pkgs.juicity;
            configFile = "${config.sops.templates."juicity-server-config.json".path}";
            allowedOpenFirewallPorts = [
              23182
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
