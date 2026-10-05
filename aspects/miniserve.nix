{
  den.aspects.miniserve.nixos =
    {
      lib,
      pkgs,
      host,
      ...
    }:
    let
      templates = {
        cinny = {
          directory = toString pkgs.cinny;
          isSpa = true;
        };
        ariang = {
          directory = "${pkgs.ariang}/share/ariang";
          isSpa = true;
        };
      };
      apps = lib.mapAttrs (
        _: app:
        {
          interface = "127.0.0.1";
          isSpa = false;
          defaultIndex = "index.html";
        }
        // lib.optionalAttrs (app ? template) templates.${app.template}
        // lib.removeAttrs app [ "template" ]
      ) (host.miniserve.apps or { });
    in
    {
      systemd.services = lib.concatMapAttrs (name: value: {
        "miniserve-${name}" = {
          description = ''
            miniserve for ${name}
          '';
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = ''
              ${lib.getExe pkgs.miniserve} ${lib.optionalString value.isSpa "--spa"} --index ${value.directory}/${value.defaultIndex} --port ${toString value.port} --interfaces ${value.interface} ${value.directory}
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
      }) apps;
    };
}
