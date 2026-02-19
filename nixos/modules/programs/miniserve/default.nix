{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.miniserve;
in {
  imports = lib.youthlic.loadImports ./.;
  options = {
    youthlic.programs.miniserve = {
      enable = lib.mkEnableOption "miniserve";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.miniserve;
      };
      templates = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
      apps = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({...}: {
          options = {
            port = lib.mkOption {
              type = lib.types.port;
            };
            interface = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
            };
            isSpa = lib.mkEnableOption "is spa";
            directory = lib.mkOption {
              type = lib.types.either lib.types.package lib.types.path;
            };
            defaultIndex = lib.mkOption {
              type = lib.types.str;
              default = "index.html";
            };
          };
        }));
        default = {};
      };
    };
  };
  config = lib.mkIf (cfg.enable && (cfg.apps != {})) {
    systemd.services =
      lib.concatMapAttrs (name: value: {
        "miniserve-${name}" = {
          description = ''
            miniserve for ${name}
          '';
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            ExecStart = ''
              ${lib.getExe cfg.package} ${lib.optionalString value.isSpa "--spa"} --index ${value.directory}/${value.defaultIndex} --port ${toString value.port} --interfaces ${value.interface} ${value.directory}
            '';
            IPAccounting = "yes";
            IPAddressAllow = value.interface;
            IPAddressDeny = "any";
            DynamicUser = "yes";
            PrivateTmp = "yes";
            PrivateUsers = "yes";
            PrivateDevices = "yes";
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = "yes";
            ProtectClock = "yes";
            ProtectControlGroups = "yes";
            ProtectKernelLogs = "yes";
            ProtectKernelModules = "yes";
            ProtectKernelTunables = "yes";
            ProtectProc = "invisible";
            CapabilityBoundingSet = [
              "CAP_NET_BIND_SERVICE"
              "CAP_DAC_READ_SEARCH"
            ];
          };
        };
      })
      cfg.apps;
  };
}
