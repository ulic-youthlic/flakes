{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.rustypaste;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "rustypaste-config.toml" cfg.settings;
in
{
  options = {
    services.rustypaste = {
      enable = lib.mkEnableOption "rustypaste";
      package = lib.mkPackageOption pkgs "rustypaste" { };
      settings = lib.mkOption {
        type = settingsFormat.type;
        default = { };
        description = ''
          Rustypaste configuration
        '';
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8000;
        example = 32456;
      };
      group = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "rustypaste";
        default = "rustypaste";
      };
      env = {
        AUTH_TOKENS_FILE = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };
        DELETE_TOKENS_FILE = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };
      };
      openFirewall = lib.mkEnableOption "open port for rustypaste";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.port
      ];
      allowedUDPPorts = [
        cfg.port
      ];
    };
    users = {
      users.rustypaste = {
        group = cfg.group;
        home = "/var/lib/rustypaste";
        isSystemUser = true;
      };
      groups = lib.optionalAttrs (cfg.group == "rustypaste") {
        rustypaste = { };
      };
    };
    systemd.services.rustypaste = {
      description = ''
        rustypaste Service
      '';
      documentation = [
        "https://github.com/orhun/rustypaste"
      ];
      after = [
        "network.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
      environment = {
        CONFIG = "${configFile}";
        AUTH_TOKENS_FILE = lib.mkIf (cfg.env.AUTH_TOKENS_FILE != null) cfg.env.AUTH_TOKENS_FILE;
        DELETE_TOKENS_FILE = lib.mkIf (cfg.env.DELETE_TOKENS_FILE != null) cfg.env.DELETE_TOKENS_FILE;
      };
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        Home = "/var/lib/rustypaste";
        ReadWritePaths = [ "/var/lib/rustypaste" ];
        StateDirectory = [ "rustypaste" ];
        ExecStart = ''
          ${lib.getExe cfg.package}
        '';
        Group = cfg.group;
        User = "rustypaste";
        RestartPreventExitStatus = 1;
      };
    };
  };
}
