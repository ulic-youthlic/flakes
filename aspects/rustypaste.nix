{ den, lib, ... }:
{
  den.aspects.rustypaste =
    { host, ... }:
    let
      cfg = {
        url = null;
      }
      // host.rustypaste;
      listen =
        if lib.hasInfix ":" cfg.listen && !(lib.hasPrefix "[" cfg.listen) then
          "[${cfg.listen}]"
        else
          cfg.listen;
      address = "${listen}:${toString cfg.port}";
      site = lib.removePrefix "https://" (lib.removePrefix "http://" cfg.url);
      withCaddy = (host.caddy.enable or false) && cfg.url != null;
    in
    {
      includes = [ den.aspects.sops ] ++ lib.optional withCaddy den.aspects.caddy;
      nixos =
        { config, pkgs, ... }:
        let
          package = cfg.package or pkgs.rustypaste;
          settings = {
            config.refresh_rate = "1s";
            server = {
              inherit address;
              upload_path = "/var/lib/rustypaste/";
              max_content_length = "10GB";
              timeout = "30s";
              expose_version = true;
              expose_list = true;
              handle_spaces = "replace";
            }
            // lib.optionalAttrs (cfg.url != null) {
              inherit (cfg) url;
            };
            paste = {
              duplicate_files = true;
              default_expiry = "3h";
              delete_expired_files = {
                enabled = true;
                interval = "3h";
              };
              random_url = {
                type = "petname";
                words = 2;
                separator = "-";
              };
              default_extension = "txt";
              main_blacklist = [
                "application/x-dosexec"
                "application/java-archive"
                "application/java-vm"
              ];
            };
            landing_page = {
              content_type = "text/plain; charset=utf-8";
              text = ''
                ┬─┐┬ ┬┌─┐┌┬┐┬ ┬┌─┐┌─┐┌─┐┌┬┐┌─┐
                ├┬┘│ │└─┐ │ └┬┘├─┘├─┤└─┐ │ ├┤
                ┴└─└─┘└─┘ ┴  ┴ ┴  ┴ ┴└─┘ ┴ └─┘

                Submit files via HTTP POST here:
                    curl -F 'file=@example.txt' <server>
                This will return the URL of the uploaded file.

                The server administrator might remove any pastes that they do not personally
                want to host.

                If you are the server administrator and want to change this page, just go
                into your config file and change it! If you change the expiry time, it is
                recommended that you do.

                By default, pastes expire every hour. The server admin may or may not have
                changed this.

                Check out the GitHub repository at https://github.com/orhun/rustypaste
                Command line tool is available  at https://github.com/orhun/rustypaste-cli
              '';
            };
          };
          configFile = (pkgs.formats.toml { }).generate "rustypaste-config.toml" settings;
        in
        {
          sops.secrets = {
            ${cfg.sops.auth.secret} = {
              group = "rustypaste";
              mode = "0440";
              inherit (cfg.sops.auth) path;
            };
            ${cfg.sops.delete.secret} = {
              group = "rustypaste";
              mode = "0440";
              inherit (cfg.sops.delete) path;
            };
          };
          environment.systemPackages = [ package ];
          networking.firewall = {
            allowedTCPPorts = [ cfg.port ];
            allowedUDPPorts = [ cfg.port ];
          };
          users = {
            users.rustypaste = {
              group = "rustypaste";
              home = "/var/lib/rustypaste";
              isSystemUser = true;
            };
            groups.rustypaste = { };
          };
          systemd.services.rustypaste = {
            description = "rustypaste Service\n";
            documentation = [ "https://github.com/orhun/rustypaste" ];
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            environment = {
              CONFIG = toString configFile;
              AUTH_TOKENS_FILE = cfg.sops.auth.path;
              DELETE_TOKENS_FILE = cfg.sops.delete.path;
            };
            serviceConfig = {
              Type = "simple";
              Restart = "on-failure";
              Home = "/var/lib/rustypaste";
              ReadWritePaths = [ "/var/lib/rustypaste" ];
              StateDirectory = [ "rustypaste" ];
              ExecStart = ''
                ${lib.getExe package}
              '';
              Group = "rustypaste";
              User = "rustypaste";
              RestartPreventExitStatus = 1;
            };
          };
          services = lib.optionalAttrs withCaddy {
            caddy.virtualHosts.${site} = {
              hostName = cfg.url;
              logFormat = ''
                output file ${config.services.caddy.logDir}/access-${
                  lib.replaceStrings [ "/" " " ] [ "_" "_" ] site
                }.log
              '';
              extraConfig = ''
                reverse_proxy ${address}
              '';
            };
          };
        };
    };
}
