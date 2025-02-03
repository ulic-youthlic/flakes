{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.youthlic.programs.juicity;
in
{
  imports = [
    ./template.nix
  ];
  options = {
    youthlic.programs.juicity = {
      client = {
        enable = lib.mkEnableOption "juicity-client";
      };
      server = {
        enable = lib.mkEnableOption "juicity-server";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.client.enable {
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
    })
    (lib.mkIf cfg.server.enable {
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
    })
    (lib.mkIf (cfg.server.enable || cfg.client.enable) {
      sops.secrets = {
        "juicity/uuid" = { };
        "juicity/password" = { };
      };
    })
  ];
}
