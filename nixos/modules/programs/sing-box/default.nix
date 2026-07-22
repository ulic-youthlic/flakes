{
  config,
  pkgs,
  lib,
  rootPath,
  ...
}:
let
  cfg = config.youthlic.programs.sing-box;
in
{
  options = {
    youthlic.programs.sing-box = {
      enable = lib.mkEnableOption "sing-box";
    };
  };
  config = lib.mkIf cfg.enable {
    sops = {
      secrets = {
        "nodes" = {
          sopsFile = rootPath + "/secrets/sing-box.yaml";
        };
        "tags" = {
          sopsFile = rootPath + "/secrets/sing-box.yaml";
        };
        "limited-tags" = {
          sopsFile = rootPath + "/secrets/sing-box.yaml";
        };
      };
      templates."sing-box-outbounds.json" = {
        content =
          let
            tags = config.sops.placeholder."tags";
            limited-tags = config.sops.placeholder."limited-tags";
          in
          # json
          ''
            [
              {
                "default": "proxy-auto",
                "outbounds": ["proxy-auto", "proxy-manual"],
                "tag": "proxy-out",
                "type": "selector"
              },
              {
                "outbounds": ${tags},
                "tag": "proxy-manual",
                "type": "selector"
              },
              {
                "outbounds": ${tags},
                "tag": "proxy-auto",
                "type": "urltest"
              },
              {
                "default": "limited-auto",
                "outbounds": ["limited-auto", "limited-manual"],
                "tag": "limited-out",
                "type": "selector"
              },
              {
                "outbounds": ${limited-tags},
                "tag": "limited-auto",
                "type": "urltest"
              },
              {
                "outbounds": ${limited-tags},
                "tag": "limited-manual",
                "type": "selector"
              },
              { "tag": "direct-out", "type": "direct" },
              ${config.sops.placeholder."nodes"}
            ]
          '';
      };
    };
    services.sing-box = {
      enable = true;
      package = pkgs.nur.repos.prince213.sing-box-beta;
      settings = {
        log = {
          disabled = false;
          level = "info";
          timestamp = false;
        };
        dns = {
          servers = [
            {
              type = "local";
              tag = "local";
              prefer_go = false;
              neighbor_domain = [ ".home.arp" ];
            }
            {
              type = "hosts";
              tag = "host";
              predefined = {
                localhost = [
                  "127.0.0.1"
                  "::1"
                ];
              };
            }
            {
              type = "https";
              tag = "alidns";
              server = "dns.alidns.com";

              # dialer
              domain_resolver = "local";
            }
            # {
            #   type = "https";
            #   tag = "google";
            #   server = "dns.google";

            #   # dialer
            #   domain_resolver = "alidns";
            #   detour = "proxy-out";
            # }
            {
              type = "https";
              tag = "cloudflare";
              server = "1.1.1.1";

              detour = "proxy-out";
            }
          ];
          rules = [
            {
              preferred_by = "host";
              action = "route";
              server = "host";
            }
            {
              clash_mode = "Direct";
              action = "route";
              server = "local";
            }
            {
              rule_set = "geosite-geolocation-cn";
              action = "route";
              server = "alidns";
            }
            {
              action = "evaluate";
              server = "local";
            }
            {
              type = "logical";
              mode = "and";
              rules = [
                {
                  rule_set = "geosite-geolocation-!cn";
                  invert = true;
                }
                {
                  match_response = true;
                  rule_set = "geoip-cn";
                }
              ];
              action = "route";
              server = "cloudflare";
            }
            {
              match_response = true;
              ip_is_private = true;
              action = "respond";
            }
          ];
          final = "cloudflare";
          # strategy = "prefer_ipv4";
          strategy = "ipv4_only";
          cache_capacity = 1000;
          optimistic = {
            enabled = true;
            timeout = "3d";
          }; # enable optimistic dns cache, when dns cache expired but without timeout, return the cache and toggle refresh in the background
          timeout = "10s"; # default timeout for every dns query. can be overrode by `rules.[].timeout` or `domain_resolver.timeout`
          reverse_mapping = false; # store reverse mapping of dns record, to provide domain name when route traffic
        };
        inbounds = [
          {
            type = "mixed";
            tag = "mixed-in";
            listen = "127.0.0.1";
            listen_port = 7799;
          }
          {
            type = "tun";
            tag = "tun-in";
            address = [
              "172.18.0.1/30"
              "fdfe:dcba:9876::1/126"
            ];
            dns_mode = "hijack";
            auto_route = true;
            auto_redirect = true;
            strict_route = true;
          }
        ];
        route = {
          rules = [
            {
              clash_mode = "Direct";
              action = "bypass";
              outbound = "direct-out";
            }
            {
              clash_mode = "Global";
              action = "route";
              outbound = "proxy-out";
            }
            {
              action = "sniff";
            }
            {
              protocol = "bittorrent";
              action = "bypass";
              outbound = "direct-out";
            }
            {
              rule_set = "geosite-geolocation-cn";
              action = "route";
              outbound = "direct-out";
            }
            {
              type = "logical";
              mode = "or";
              rules = [
                { rule_set = "geosite-google-gemini"; }
                { rule_set = "geosite-local-gemini"; }
              ];
              action = "route";
              outbound = "limited-out";
            }
            {
              rule_set = "geosite-category-ai-!cn";
              action = "route";
              outbound = "limited-out";
            }
            {
              rule_set = "geosite-spotify";
              action = "route";
              outbound = "limited-out";
            }
            {
              domain_keyword = "factorio";
              action = "route";
              outbound = "direct-out";
            }
            {
              action = "resolve";
            }
          ];
          final = "proxy-out"; # tag of default outbound
          auto_detect_interface = true;
          default_domain_resolver = {
            server = "alidns";
          };
          rule_set = [
            {
              type = "remote";
              tag = "geosite-geolocation-cn";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-cn.srs";
            }
            {
              type = "remote";
              tag = "geosite-geolocation-!cn";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-!cn.srs";
            }
            {
              type = "remote";
              tag = "geosite-category-ai-!cn";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ai-!cn.srs";
            }
            {
              type = "remote";
              tag = "geoip-cn";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
            }
            {
              type = "remote";
              tag = "geosite-spotify";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-spotify.srs";
            }
            {
              type = "remote";
              tag = "geosite-google-gemini";
              format = "binary";
              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-google-gemini.srs";
            }
            {
              type = "local";
              tag = "geosite-local-gemini";
              format = "source";
              path = toString ./gemini.json;
            }
          ];
        };
        outbounds = {
          _secret = "${config.sops.templates."sing-box-outbounds.json".path}";
          quote = false;
        };
        services = [
          {
            type = "api";
            listen = "127.0.0.1";
            listen_port = 9199;
            access_control_allow_private_network = true;
            dashboard.enabled = true;
            tls.enabled = false;
          }
        ];
        experimental = {
          cache_file = {
            enabled = true;
            store_dns = true;
          };
          clash_api = {
            external_controller = "127.0.0.1:9099";
            external_ui = "clash_dashboard";
            default_mode = "Rule";
          };
        };
      };
    };
  };
}
