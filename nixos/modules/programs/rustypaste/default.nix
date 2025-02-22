{ lib, config, ... }:
let
  cfg = config.youthlic.programs.rustypaste;
in
{
  imports = [
    ./template.nix
  ];

  options = {
    youthlic.programs.rustypaste = {
      enable = lib.mkEnableOption "rustypaste";
      listen = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "0.0.0.0";
        default = "127.0.0.1";
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;
        example = "https://paste.example.com";
        default = null;
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops.secrets = {
        "rustypaste/auth" = {
          group = "rustypaste";
          mode = "0440";
        };
        "rustypaste/delete" = {
          group = "rustypaste";
          mode = "0440";
        };
      };
      services.rustypaste = {
        enable = true;
        port = 8483;
        group = "rustypaste";
        settings = {
          config = {
            refresh_rate = "1s";
          };
          server = {
            address = "${cfg.listen}:8483";
            url = lib.mkIf (cfg.url != null) cfg.url;
            upload_path = "/var/lib/rustypaste/";
            max_content_length = "10GB";
            timeout = "30s";
            expose_version = true;
            expose_list = true;
            handle_spaces = "replace";
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
            mine_override = [
              {
                mime = "image/jpeg";
                regex = "^.*\\.jpg$";
              }
              {
                mime = "image/png";
                regex = "^.*\\.png$";
              }
              {
                mime = "image/svg+xml";
                regex = "^.*\\.svg$";
              }
              {
                mime = "video/webm";
                regex = "^.*\\.webm$";
              }
              {
                mime = "video/x-matroska";
                regex = "^.*\\.mkv$";
              }
              {
                mime = "application/octet-stream";
                regex = "^.*\\.bin$";
              }
              {
                mime = "text/plain";
                regex = "^.*\\.(log|txt|diff|sh|rs|toml|py|json|yaml|yml|ts|js|go|c|C|c++|cpp|cxx|patch|toml|bash|fish)$";
              }
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
        env = {
          AUTH_TOKENS_FILE = "${config.sops.secrets."rustypaste/auth".path}";
          DELETE_TOKENS_FILE = "${config.sops.secrets."rustypaste/delete".path}";
        };
        openFirewall = true;
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "paste.${config.youthlic.programs.caddy.baseDomain}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8483
          '';
        };
      };
    })
  ];
}
