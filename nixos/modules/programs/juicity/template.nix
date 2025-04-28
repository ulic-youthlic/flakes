{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.juicity;
  settingsFormat = pkgs.formats.json {};
  clientConfigFile =
    if (cfg.client.configFile != null)
    then cfg.client.configFile
    else settingsFormat cfg.client.settings;
  serverConfigFile =
    if (cfg.server.configFile != null)
    then cfg.server.configFile
    else settingsFormat cfg.server.settings;
in {
  options = {
    services.juicity = {
      client = {
        enable = lib.mkEnableOption "juicity-client";
        package = lib.mkPackageOption pkgs "juicity" {};
        group = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          example = "juicity";
          default = null;
        };
        settings = lib.mkOption {
          type = settingsFormat.type;
          default = {};
          example = {
            listen = ":1000";
            server = "112.32.62.11:23182";
            uuid = "00000000-0000-0000-0000-000000000000";
            password = "my_password";
            sni = "www.example.com";
            allow_insecure = false;
            congestion_control = "bbr";
            log_level = "info";
          };
          description = ''
            Juicity client configuration, for configuration options
            see example of [client](https://github.com/juicity/juicity/blob/main/install/example-client.json) on github.
          '';
        };
        configFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          example = "/run/juicity/config.json";
          default = null;
          description = ''
            A file which JSON configurations for juicity client. See the {option}`settings` option for more information.

            Note: this file will override {options}`settings` option, which is recommanded.
          '';
        };
        allowedOpenFirewallPorts = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.port);
          example = [23182];
          default = null;
          description = ''
            the ports should be open
          '';
        };
      };
      server = {
        enable = lib.mkEnableOption "juicity-server";
        package = lib.mkPackageOption pkgs "juicity" {};
        group = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          example = "juicity";
          default = null;
        };
        settings = lib.mkOption {
          type = settingsFormat.type;
          default = {};
          description = ''
            Juicity server configuration, for configuration options
            see example of [server](https://github.com/juicity/juicity/blob/main/install/example-server.json) on github.
          '';
          example = {
            listen = ":23182";
            users = {
              "00000000-0000-0000-0000-000000000000" = "my_password";
            };
            certificate = "/path/to/fullchain.cer";
            private_key = "/path/to/private.key";
            congestion_control = "bbr";
            log_level = "info";
          };
        };
        configFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          example = "/run/juicity/config.json";
          default = null;
          description = ''
            A file which JSON configurations for juicity server. See the {option}`settings` option for more information.

            Note: this file will override {options}`settings` option, which is recommanded.
          '';
        };
        allowedOpenFirewallPorts = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.port);
          example = [23182];
          default = null;
          description = ''
            the ports should be open
          '';
        };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.client.enable && (cfg.client.allowedOpenFirewallPorts != null)) {
      networking.firewall.allowedTCPPorts = cfg.client.allowedOpenFirewallPorts;
      networking.firewall.allowedUDPPorts = cfg.client.allowedOpenFirewallPorts;
    })
    (lib.mkIf (cfg.server.enable && (cfg.server.allowedOpenFirewallPorts != null)) {
      networking.firewall.allowedTCPPorts = cfg.server.allowedOpenFirewallPorts;
      networking.firewall.allowedUDPPorts = cfg.server.allowedOpenFirewallPorts;
    })
    (lib.mkIf (cfg.server.enable && (cfg.server.group != null)) {
      systemd.services."juicity-server".serviceConfig = {
        Group = cfg.server.group;
      };
    })
    (lib.mkIf (cfg.client.enable && (cfg.client.group != null)) {
      systemd.services."juicity-client".serviceConfig = {
        Group = cfg.client.group;
      };
    })
    (lib.mkIf cfg.client.enable {
      environment.systemPackages = [
        cfg.client.package
      ];
      systemd.services.juicity-client = {
        description = ''
          juicity-client Service
        '';
        documentation = [
          "https://github.com/juicity/juicity"
        ];
        after = [
          "network.target"
          "nss-lookup.target"
        ];
        wantedBy = [
          "multi-user.target"
        ];
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_RAW"
          ];
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_RAW"
          ];
          ExecStart = ''
            ${lib.getExe' cfg.client.package "juicity-client"} run --disable-timestamp --config ${clientConfigFile}
          '';
          Restart = "on-failure";
          LimitNPROC = 512;
          LimitNOFILE = "infinity";
        };
      };
    })
    (lib.mkIf cfg.server.enable {
      environment.systemPackages = [
        cfg.server.package
      ];
      systemd.services.juicity-server = {
        description = ''
          juicity-server Service
        '';
        documentation = [
          "https://github.com/juicity/juicity"
        ];
        after = [
          "network.target"
          "nss-lookup.target"
        ];
        wantedBy = [
          "multi-user.target"
        ];
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          ExecStart = ''
            ${lib.getExe' cfg.server.package "juicity-server"} run --disable-timestamp --config ${serverConfigFile}
          '';
          Restart = "on-failure";
          LimitNPROC = 512;
          LimitNOFILE = "infinity";
        };
      };
    })
  ];
}
